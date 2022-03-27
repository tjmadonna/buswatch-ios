//
//  PredictionNetworkDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol PredictionNetworkDataSource {

    func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[NetworkPrediction], Error>

}
