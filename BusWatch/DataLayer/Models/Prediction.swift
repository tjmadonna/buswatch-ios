//
//  Prediction.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/29/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

struct Prediction {
    let vehicleId: String
    let routeId: String
    let routeTitle: String
    let arrivalTime: Date
}

extension Prediction: Hashable { }
