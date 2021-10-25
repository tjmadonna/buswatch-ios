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

    private let routesLocalDataStore: RouteLocalDataStore

    init(routesLocalDataStore: RouteLocalDataStore, urlSession: URLSession = URLSession.shared) {
        self.routesLocalDataStore = routesLocalDataStore
        self.urlSession = urlSession
    }

    func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[Prediction], Error> {
        let url = NetworkConfig.authenticatedURLPredictionsForStopId(stopId)
        return TimedNetworkPublisher<GetPredictionsForStopIdResponseDecodable>(url: url, timeInterval: 30)
            .map { response in response.bustimeResponse?.predictions ?? [] }
            .tryMap { predictions in
                let routeIds = predictions.compactMap { $0.routeId }
                let routes = (try? self.routesLocalDataStore.getRoutesWithIds(routeIds)) ?? []
                let routesDict = Dictionary(uniqueKeysWithValues: routes.map { ($0.id, $0) })
                return predictions.compactMap { prediction in
                    prediction.mapToPrediction(route: routesDict[prediction.routeId ?? ""])
                }
            }
            .eraseToAnyPublisher()
    }
}
