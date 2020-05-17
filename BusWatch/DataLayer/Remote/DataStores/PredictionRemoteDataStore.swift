//
//  PredictionRemoteDataStore.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/2/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

enum NetworkError: Error {
    case responseNot200
}

final class PredictionRemoteDataStore {

    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[Prediction], Error> {
        let url = NetworkConfig.authenticatedURLPredictionsForStopId(stopId)
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { (data, response) in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200 ... 299 ~= statusCode else {
                    throw NetworkError.responseNot200
                }
                return data
            }
            .decode(type: PredictionsResponseDecodable.self, decoder: JSONDecoder())
            .compactMap { response in response.predictions }
            .map { predictions in predictions.compactMap { prediction in prediction.mapToPrediction() } }
            .eraseToAnyPublisher()
    }
}
