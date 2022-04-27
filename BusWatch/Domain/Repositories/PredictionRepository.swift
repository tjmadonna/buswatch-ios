//
//  PredictionRepository.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol PredictionRepository {

    func getPredictionsForStopId(_ stopId: String, serviceType: ServiceType) -> AnyPublisher<[Prediction], Error>

}
