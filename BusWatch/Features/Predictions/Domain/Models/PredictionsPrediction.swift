//
//  PredictionsPrediction.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/29/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

struct PredictionsPrediction {
    let vehicleId: String
    let arrivalTime: Date
    let destination: String
    let direction: String
    let capacity: PredictionsCapacityType
    let routeId: String
    let routeTitle: String?
    let routeColor: String?
}

extension PredictionsPrediction: Hashable { }
