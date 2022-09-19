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

    func observePredictionsForStopId(_ stopId: String,
                                     serviceType: ServiceType,
                                     updateInterval: TimeInterval) -> AnyPublisher<[NetworkPrediction], Error>

}

final class NetworkDataSourceImpl: NetworkDataSource {

    private let urlSource: UrlSource

    private let urlSession: URLSession

    init(urlSource: UrlSource, urlSession: URLSession = URLSession.shared) {
        self.urlSource = urlSource
        self.urlSession = urlSession
    }

    func observePredictionsForStopId(_ stopId: String,
                                     serviceType: ServiceType,
                                     updateInterval: TimeInterval) -> AnyPublisher<[NetworkPrediction], Error> {

        let url = urlSource.authenticatedPredictionsURLForStopId(stopId, serviceType: serviceType)
        return TimedNetworkPublisher(url: url, timeInterval: updateInterval, urlSession: urlSession)
            .decode(type: NetworkGetPredictionsResponse.self, decoder: JSONDecoder())
            .tryMap { (response: NetworkGetPredictionsResponse) -> [NetworkPrediction] in
                if let errors = response.bustimeResponse?.errors {
                    if errors.first?.message?.lowercased() == "no service scheduled" ||
                        errors.first?.message?.lowercased() == "no arrival times" {
                        // Api returns an error json response if there's no predictions
                        return []
                    }
                    return []
                }
                return response.bustimeResponse?.predictions ?? []
            }
            .eraseToAnyPublisher()
    }

}
