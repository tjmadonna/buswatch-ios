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
struct TimedNetworkPublisher<T>: Publisher where T: Decodable {

    fileprivate enum Error: Swift.Error {
        case invalidResponse
        case rateLimitted
        case serverBusy
        case endpoint
    }

    typealias Output = LoadingResponse<T>

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

        private let decoder: JSONDecoder = JSONDecoder()

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

            _ = downstream?.receive(.loading)
            requestCancellable = urlSession.dataTaskPublisher(for: url)
                .tryMap { [unowned self] (data, response) in
                    try self.tryToMapNetworkResponse(data: data, response: response)
                }
                .catch { [unowned self] error in
                    self.catchError(error)
                }
                .retry(2)
                .tryMap { (result: DataResult) -> Data in
                    return try result.get()
                }
                .decode(type: T.self, decoder: decoder)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            _ = self?.downstream?.receive(.failure(error))
                        }
                        self?.requestInProgess = false
                    },
                    receiveValue: { [weak self] (value: T) in
                        _ = self?.downstream?.receive(.success(value))
                    })
        }

        func cancel() {
            requestCancellable?.cancel()
            requestCancellable = nil
            timer?.invalidate()
            timer = nil
        }

        private func tryToMapNetworkResponse(data: Data, response: URLResponse) throws -> DataResult {
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

        private func catchError(_ error: Swift.Error) -> AnyPublisher<DataResult, Swift.Error> {
            switch error {
            case TimedNetworkPublisher.Error.rateLimitted, TimedNetworkPublisher.Error.serverBusy:
                return Fail<DataResult, Swift.Error>(error: error)
                    .delay(for: 3, scheduler: DispatchQueue.main)
                    .eraseToAnyPublisher()
            default:
                return Just(.failure(error))
                    .setFailureType(to: Swift.Error.self)
                    .eraseToAnyPublisher()
            }
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
