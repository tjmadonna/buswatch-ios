//
//  PredictionDecodable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/30/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

struct PredictionDecodable: Decodable {

    let vehicleId: String?

    let routeId: String?

    let routeTitle: String?

    let arrivalTime: Int?

    private enum CodingKeys: String, CodingKey {
        case vehicleId = "vehicleId"
        case routeId = "routeId"
        case routeTitle = "routeTitle"
        case arrivalTime = "arrivalTime"
    }

    private var arriveTimeAsDate: Date? {
        guard let arrivalTime = arrivalTime else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(arrivalTime))
    }

    func mapToPrediction() -> Prediction? {
        guard let vehicleId = vehicleId,
            let routeId = routeId,
            let routeTitle = routeTitle,
            let arrivalTime = arriveTimeAsDate  else {
            return nil
        }
        return Prediction(vehicleId: vehicleId, routeId: routeId, routeTitle: routeTitle, arrivalTime: arrivalTime)
    }
}
