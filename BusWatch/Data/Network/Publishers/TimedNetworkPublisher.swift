//
//  TimedNetworkPublisher.swift
//  BusWatch
//
//  Created by Tyler Madonna on 9/19/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation

/// Publisher that periodically makes a network request and decodes response into a specified decodable type
struct TimedNetworkPublisher: Publisher {

    fileprivate enum Error: Swift.Error {
        case invalidResponse
        case rateLimitted
        case serverBusy
        case endpoint
    }

    typealias Output = Data

    typealias Failure = Swift.Error

    // URL for the network request
    private let url: URL

    // Time interval between network requests
    private let timeInterval: TimeInterval

    // URL session used for the network request
    private let urlSession: URLSession

    init(url: URL, timeInterval: TimeInterval, urlSession: URLSession = URLSession.shared) {
        self.url = url
        self.timeInterval = timeInterval
        self.urlSession = urlSession
    }

    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Inner(downstream: subscriber, url: url, timeInterval: timeInterval)
        subscriber.receive(subscription: subscription)
    }

    /// Subscription returned by TimedNetworkPublisher
    private final class Inner<S>: Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {

        typealias DataResult = Result<Data, Swift.Error>

        // MARK: - Properties

        // URL for the network request
        private let url: URL

        // Time interval between network requests
        private let timeInterval: TimeInterval

        // URL session used for the network request
        private let urlSession: URLSession

        // MARK: -

        // Downstream subscription
        private var downstream: S?

        // Timer for making scheduled network request
        private var timer: Timer?

        // Cancellable for the network call and decoding
        private var requestCancellable: AnyCancellable?

        // Atomic variable that indicates if a network request is in progress
        @Atomic
        private var requestInProgess = false

        init(downstream: S, url: URL, timeInterval: TimeInterval, urlSession: URLSession = URLSession.shared) {
            self.downstream = downstream
            self.url = url
            self.timeInterval = timeInterval
            self.urlSession = urlSession
        }

        func request(_ demand: Subscribers.Demand) {
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                             target: self,
                                             selector: #selector(makeNetworkRequest),
                                             userInfo: nil,
                                             repeats: true)
                timer?.fire()
            }
        }

        @objc private func makeNetworkRequest() {
            // Only allow one network request at a time
            if requestInProgess { return }
            requestInProgess = true

            requestCancellable = urlSession.dataTaskPublisher(for: url)
                .tryMap { (data: Data, response: URLResponse) -> DataResult in
                    guard let response = response as? HTTPURLResponse else {
                        return .failure(Error.invalidResponse)
                    }

                    if response.statusCode == 429 {
                        throw Error.rateLimitted
                    }

                    if response.statusCode == 503 {
                        throw Error.serverBusy
                    }

                    return .success(data)
                }
                .catch { (error: Swift.Error) -> AnyPublisher<DataResult, Swift.Error> in

                    switch error {
                    case Error.rateLimitted, Error.serverBusy:
                        return Fail<DataResult, Swift.Error>(error: error)
                            .delay(for: 3, scheduler: DispatchQueue.main)
                            .eraseToAnyPublisher()
                    default:
                        return Just(.failure(error))
                            .setFailureType(to: Swift.Error.self)
                            .eraseToAnyPublisher()
                    }
                }
                .retry(2)
                .tryMap { (result: DataResult) -> Data in
                    return try result.get()
                }
                .sink(
                    receiveCompletion: { [weak self] _ in
                        self?.requestInProgess = false
                    },
                    receiveValue: { [weak self] (data: Data) in
                        _ = self?.downstream?.receive(data)
                    })
        }

        func cancel() {
            requestCancellable?.cancel()
            requestCancellable = nil
            timer?.invalidate()
            timer = nil
        }
    }
}

/// Property wrapper for an atomic value
@propertyWrapper
private struct Atomic<Value> {

    // Lock for when we access the value
    private let lock = NSLock()

    private var value: Value

    var wrappedValue: Value {
        get { return getValue() }
        set { setValue(newValue) }
    }

    init(wrappedValue value: Value) {
        self.value = value
    }

    private func getValue() -> Value {
        // Lock when we get the value
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    private mutating func setValue(_ value: Value) {
        // Lock when we mutate value
        lock.lock()
        defer { lock.unlock() }
        self.value = value
    }
}
