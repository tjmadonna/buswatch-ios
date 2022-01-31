//
//  GetPredictionsForStopId.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionsGetPredictionsForStopId {

    private let predictionRepository: PredictionsPredictionRepository

    init(predictionRepository: PredictionsPredictionRepository) {
        self.predictionRepository = predictionRepository
    }

    func execute(stopId: String) -> AnyPublisher<[PredictionsPrediction], Error> {
        return predictionRepository.getPredictionsForStopId(stopId)
    }
}
