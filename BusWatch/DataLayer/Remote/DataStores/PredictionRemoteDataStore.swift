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
    case noDataInResponse
}

final class PredictionRemoteDataStore {

    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[Prediction], Error> {
        let url = NetworkConfig.authenticatedURLPredictionsForStopId(stopId)
        return TimedNetworkPublisher<GetPredictionsForStopIdResponseDecodable>(url: url, timeInterval: 30)
            .compactMap { response in response.bustimeResponse?.predictions }
            .map { predictions in predictions.compactMap { prediction in prediction.mapToPrediction() } }
            .eraseToAnyPublisher()
    }
}
