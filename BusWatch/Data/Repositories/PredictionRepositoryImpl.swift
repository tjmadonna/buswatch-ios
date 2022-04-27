//
//  PredictionRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionRepositoryImpl: PredictionRepository {

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyyMMdd HH:mm"
        return dateFormatter
    }()

    private let predictionApi: PredictionNetworkDataSource

    private let routeDatabase: RouteDatabaseDataSource

    init(predictionApi: PredictionNetworkDataSource, routeDatabase: RouteDatabaseDataSource) {
        self.predictionApi = predictionApi
        self.routeDatabase = routeDatabase
    }

    func getPredictionsForStopId(_ stopId: String, serviceType: ServiceType) -> AnyPublisher<[Prediction], Error> {
        return predictionApi.getPredictionsForStopId(stopId, serviceType: serviceType)
            .combineLatest(routeDatabase.getExcludedRouteIdsForStopId(stopId))
            .map { (predictions, excludedRouteIds) in
                let excludedRouteIdSet = Set(excludedRouteIds)
                return predictions.filter { prediction in
                    prediction.routeId == nil || !excludedRouteIdSet.contains(prediction.routeId!)
                }
            }
            .flatMap { self.getRoutesForDataPredictions($0) }
            .map { [unowned self] (predictions, routes) in
                let routesDict = Dictionary(uniqueKeysWithValues: routes.map { ($0.id, $0) })
                return predictions.compactMap { prediction in
                    prediction.toPrediction(route: routesDict[prediction.routeId!], dateFormatter: self.dateFormatter)
                }
            }
            .eraseToAnyPublisher()
    }

    private func getRoutesForDataPredictions(_ predictions: [NetworkPrediction])
        -> AnyPublisher<([NetworkPrediction], [DatabaseRoute]), Error> {

        let routeIds = predictions.compactMap { $0.routeId }
        return routeDatabase.getRoutesWithIds(routeIds)
            .first()
            .map { (predictions, $0) }
            .eraseToAnyPublisher()
    }
}
