//
//  PredictionsPredictionMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

final class PredictionsPredictionMapper {

    func mapDataPredictionArrayToDomainPredictionArray(_ dataPredictions: [PredictionsDataPrediction]?,
                                                       routes: [PredictionsDataRoute]?)
        -> [PredictionsPrediction]? {

        guard let dataPredictions = dataPredictions else { return nil }
        let routes = routes ?? []
        let routesDict = Dictionary(uniqueKeysWithValues: routes.map { ($0.id, $0) })
        let predictions = dataPredictions.compactMap { prediction -> PredictionsPrediction? in
            self.mapDataPredictionToDomainPrediction(prediction, route: routesDict[prediction.routeId])
        }

        if predictions.isEmpty {
            return nil
        } else {
            return predictions
        }
    }

    func mapDataPredictionToDomainPrediction(_ dataPrediction: PredictionsDataPrediction?,
                                             route: PredictionsDataRoute?) -> PredictionsPrediction? {

        guard let dataPrediction = dataPrediction else { return nil }

        return PredictionsPrediction(
            vehicleId: dataPrediction.vehicleId,
            arrivalTime: dataPrediction.arrivalTime,
            destination: dataPrediction.destination,
            direction: dataPrediction.routeDirection,
            capacity: dataPrediction.capacity,
            routeId: dataPrediction.routeId,
            routeTitle: route?.title,
            routeColor: route?.color
        )
    }
}
