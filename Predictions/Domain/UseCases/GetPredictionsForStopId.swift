//
//  GetPredictionsForStopId.swift
//  Predictions
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class GetPredictionsForStopId {

    private let predictionRepository: PredictionRepositoryRepresentable

    public init(predictionRepository: PredictionRepositoryRepresentable) {
        self.predictionRepository = predictionRepository
    }

    func execute(stopId: String) -> AnyPublisher<[Prediction], Error> {
        return predictionRepository.getPredictionsForStopId(stopId)
    }
}
