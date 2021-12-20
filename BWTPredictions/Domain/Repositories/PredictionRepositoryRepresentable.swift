//
//  PredictionRepositoryRepresentable.swift
//  Predictions
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public protocol PredictionRepositoryRepresentable {

    func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[Prediction], Error>

}
