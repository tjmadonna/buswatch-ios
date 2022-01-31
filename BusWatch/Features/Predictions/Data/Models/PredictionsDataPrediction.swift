//
//  PredictionsDataPrediction.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

struct PredictionsDataPrediction {
    let vehicleId: String
    let routeId: String
    let destination: String
    let routeDirection: String
    let arrivalTime: Date
    let capacity: PredictionsCapacityType
}
