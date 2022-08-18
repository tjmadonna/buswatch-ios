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
        case endpoint
        case non200
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
            .tryMap { (data, response) in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200 ... 299 ~= statusCode else {
                    throw Error.non200
                }
                return data
            }
            .decode(type: NetworkGetPredictionsResponse.self, decoder: JSONDecoder())
            .tryMap { response -> [NetworkPrediction] in

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
