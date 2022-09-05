//
//  NetworkDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation

protocol NetworkDataSource {

    func getPredictionsForStopId(_ stopId: String,
                                 serviceType: ServiceType)-> AnyPublisher<[NetworkPrediction], Swift.Error>

}

final class NetworkDataSourceImpl: NetworkDataSource {

    enum Error: Swift.Error {
        case invalidResponse
        case rateLimitted
        case serverBusy
        case endpoint
    }

    private let urlSource: UrlSource

    private let urlSession: URLSession

    init(urlSource: UrlSource, urlSession: URLSession = URLSession.shared) {
        self.urlSource = urlSource
        self.urlSession = urlSession
    }

    func getPredictionsForStopId(_ stopId: String,
                                 serviceType: ServiceType) -> AnyPublisher<[NetworkPrediction], Swift.Error> {

        let url = urlSource.authenticatedPredictionsURLForStopId(stopId, serviceType: serviceType)
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { (data: Data, response: URLResponse) -> Result<Data, Swift.Error> in
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
            .catch { (error: Swift.Error) -> AnyPublisher<Result<Data, Swift.Error>, Swift.Error> in
                switch error {
                case Error.rateLimitted, Error.serverBusy:
                    // Retryable error
                    return Fail(error: error)
                        .delay(for: 3, scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                default:
                    // Non-retryable error
                    return Just(.failure(error))
                        .setFailureType(to: Swift.Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .retry(2)
            .tryMap { result in
                return try result.get()
            }
            .decode(type: NetworkGetPredictionsResponse.self, decoder: JSONDecoder())
            .tryMap { (response: NetworkGetPredictionsResponse) -> [NetworkPrediction] in
                if let errors = response.bustimeResponse?.errors {
                    if errors.first?.message?.lowercased() == "no service scheduled" ||
                        errors.first?.message?.lowercased() == "no arrival times" {
                        // Api returns an error json response if there's no predictions
                        return []
                    }
                    throw Error.endpoint
                }
                return response.bustimeResponse?.predictions ?? []
            }
            .eraseToAnyPublisher()
    }

}
