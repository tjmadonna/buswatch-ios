//
//  PredictionsPredictionRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionsPredictionRepositoryImpl: PredictionsPredictionRepository {

    private let predictionDataSource: PredictionsPredictionDataSource

    private let routeDataSource: PredictionsRouteDataSource

    private let mapper: PredictionsPredictionMapper

    init(predictionDataSource: PredictionsPredictionDataSource,
         routeDataSource: PredictionsRouteDataSource,
         mapper: PredictionsPredictionMapper = PredictionsPredictionMapper()) {
        self.predictionDataSource = predictionDataSource
        self.routeDataSource = routeDataSource
        self.mapper = mapper
    }

    // MARK: - PredictionsPredictionRepository

    func getPredictionsForStopId(_ stopId: String)  -> AnyPublisher<[PredictionsPrediction], Error> {
        return predictionDataSource.getPredictionsForStopId(stopId)
            .combineLatest(routeDataSource.getExcludedRouteIdsForStopId(stopId))
            .map { (predictions, excludedRoutes) in
                let excludedRoutesSet = Set(excludedRoutes)
                return predictions.filter { prediction in !excludedRoutesSet.contains(prediction.routeId) }
            }
            .flatMap { self.getRoutesForDataPredictions($0) }
            .map { self.mapper.mapDataPredictionArrayToDomainPredictionArray($0, routes: $1)}
            .eraseToAnyPublisher()
    }

    // MARK: - Helper functions

    private func getRoutesForDataPredictions(
        _ dataPredictions: [PredictionsDataPrediction]
    ) -> AnyPublisher<([PredictionsDataPrediction], [PredictionsDataRoute]), Error> {

        let routeIds = dataPredictions.map { prediction in prediction.routeId }
        return routeDataSource.getRoutesWithIds(routeIds)
            .first()
            .map { (dataPredictions, $0) }
            .eraseToAnyPublisher()
    }
}
