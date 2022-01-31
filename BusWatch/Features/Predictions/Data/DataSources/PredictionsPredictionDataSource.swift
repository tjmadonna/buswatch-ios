//
//  PredictionsPredictionDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol PredictionsPredictionDataSource {

    func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[PredictionsDataPrediction], Error>

}
