//
//  PredictionService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation

protocol PredictionService {

    func getPredictionsForStopId(_ stopId: String, serviceType: ServiceType) -> AnyPublisher<[Prediction], Swift.Error>

}

final class PredictionServiceImpl: PredictionService {

    enum Error: Swift.Error {
        case endpoint
    }

    static private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyyMMdd HH:mm"
        return dateFormatter
    }()

    private let networkDataSource: NetworkDataSource

    private let routeDataSource: RouteDbDataSource

    init(networkDataSource: NetworkDataSource, routeDataSource: RouteDbDataSource) {
        self.networkDataSource = networkDataSource
        self.routeDataSource = routeDataSource
    }

    func getPredictionsForStopId(_ stopId: String,
                                 serviceType: ServiceType) -> AnyPublisher<[Prediction], Swift.Error> {

        return networkDataSource.getPredictionsForStopId(stopId, serviceType: serviceType)
            .flatMap { [unowned self] (predictions: [NetworkPrediction]) -> AnyPublisher<[Prediction], Swift.Error> in
                let routeIds = predictions.compactMap { prediction in prediction.routeId }
                return self.mapNetworkPredictions(predictions, using: routeIds)
            }
            .eraseToAnyPublisher()
    }

    private func mapNetworkPredictions(_ predictions: [NetworkPrediction],
                                       using routeIds: [String]) -> AnyPublisher<[Prediction], Swift.Error> {
        return routeDataSource.observeRoutesWithIds(routeIds)
            .map { (routes: [DbRoute]) -> [Prediction] in
                let routeMap = Dictionary(uniqueKeysWithValues: routes.map { route in (route.id, route) })
                return predictions.compactMap { prediction in
                    prediction.toPrediction(route: routeMap[prediction.routeId ?? ""],
                                            dateFormatter: PredictionServiceImpl.dateFormatter)
                }
            }
            .eraseToAnyPublisher()
    }

}
