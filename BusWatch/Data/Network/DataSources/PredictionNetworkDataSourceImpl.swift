//
//  PredictionNetworkDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionNetworkDataSourceImpl: PredictionNetworkDataSource {

    enum Error: Swift.Error {
        case endpoint
    }

    private let urlSource: UrlSource

    private let urlSession: URLSession

    init(urlSource: UrlSource,
         urlSession: URLSession = URLSession.shared) {
        self.urlSource = urlSource
        self.urlSession = urlSession
    }

    func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[NetworkPrediction], Swift.Error> {
        let url = urlSource.authenticatedPredictionsURLForStopId(stopId)
        return TimedNetworkPublisher(url: url,
                                     timeInterval: 30,
                                     urlSession: self.urlSession)
            .decode(type: NetworkGetPredictionsResponse.self, decoder: JSONDecoder())
            .tryMap { response in

                if let errors = response.bustimeResponse?.errors {
                    if errors.first?.message == "No service scheduled" {
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
