//
//  GetPredictionsForStopIdDecodables.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/14/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

struct PredictionDecodable: Decodable {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyyMMdd HH:mm"
        return dateFormatter
    }()

    let vehicleId: String?

    let routeId: String?

    let destination: String?

    let routeDirection: String?

    let arrivalTime: String?

    private enum CodingKeys: String, CodingKey {
        case vehicleId = "vid"
        case routeId = "rt"
        case destination = "des"
        case routeDirection = "rtdir"
        case arrivalTime = "prdtm"
    }

    private var arriveTimeAsDate: Date? {
        guard let arrivalTime = arrivalTime else { return nil }
        return PredictionDecodable.dateFormatter.date(from: arrivalTime)
    }

    func mapToPrediction() -> Prediction? {
        guard let vehicleId = vehicleId,
            let routeId = routeId,
            let destination = destination,
            let routeDirection = routeDirection,
            let arrivalTime = arriveTimeAsDate else {
                return nil
        }
        return Prediction(vehicleId: vehicleId,
                          routeId: routeId,
                          routeTitle: "\(destination) - \(routeDirection.capitalizingOnlyFirstLetter())",
                          arrivalTime: arrivalTime)
    }
}
 
struct BustimeResponseDecodable: Decodable {

    let predictions: [PredictionDecodable]?

    private enum CodingKeys: String, CodingKey {
        case predictions = "prd"
    }
}

struct GetPredictionsForStopIdResponseDecodable: Decodable {

    let bustimeResponse: BustimeResponseDecodable?

    enum CodingKeys: String, CodingKey {
        case bustimeResponse = "bustime-response"
    }
}
