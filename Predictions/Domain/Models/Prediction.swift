//
//  Prediction.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/29/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

public struct Prediction {
    let vehicleId: String
    let arrivalTime: Date
    let destination: String
    let direction: String
    let capacity: CapacityType
    let routeId: String
    let routeTitle: String?
    let routeColor: String?
}

extension Prediction: Hashable { }

enum CapacityType {
    case empty
    case halfEmpty
    case full
    case notAvailable
}
