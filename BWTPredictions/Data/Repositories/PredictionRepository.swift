//
//  PredictionRepository.swift
//  Predictions
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class PredictionRepository : PredictionRepositoryRepresentable {

    private let predictionDataSource: PredictionDataSourceRepresentable

    private let routeDataSource: RouteDataSourceRepresentable

    private let mapper: PredictionMapper

    public init(predictionDataSource: PredictionDataSourceRepresentable,
                routeDataSource: RouteDataSourceRepresentable,
                mapper: PredictionMapper = PredictionMapper()) {
        self.predictionDataSource = predictionDataSource
        self.routeDataSource = routeDataSource
        self.mapper = mapper
    }

    public func getPredictionsForStopId(_ stopId: String)  -> AnyPublisher<[Prediction], Error> {
        return predictionDataSource.getPredictionsForStopId(stopId)
            .combineLatest(routeDataSource.getExcludedRouteIdsForStopId(stopId))
            .map { (predictions, excludedRoutes) in
                let excludedRoutesSet = Set(excludedRoutes)
                return predictions.filter { prediction in !excludedRoutesSet.contains(prediction.routeId) }
            }
            .flatMap { self.getRoutesForDataPredictions($0) }
            .map { self.mapper.mapDataPredictionArrayToDomainPredictionArray($0, routes: $1) ?? [] }
            .eraseToAnyPublisher()
    }

    private func getRoutesForDataPredictions(
        _ dataPredictions: [DataPrediction]
    ) -> AnyPublisher<([DataPrediction], [DataRoute]), Error> {

        let routeIds = dataPredictions.map { p in p.routeId }
        return routeDataSource.getRoutesWithIds(routeIds)
            .first()
            .map { (dataPredictions, $0) }
            .eraseToAnyPublisher()
    }
}
