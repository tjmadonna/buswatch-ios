//
//  GetPredictionsForStopIdDecodables.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/14/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

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

    let capacity: String?

    private enum CodingKeys: String, CodingKey {
        case vehicleId = "vid"
        case routeId = "rt"
        case destination = "des"
        case routeDirection = "rtdir"
        case arrivalTime = "prdtm"
        case capacity = "psgld"
    }

    private var arriveTimeAsDate: Date? {
        guard let arrivalTime = arrivalTime else { return nil }
        return PredictionDecodable.dateFormatter.date(from: arrivalTime)
    }

    private var capacityType: CapacityType {
        switch capacity?.lowercased() {
        case "empty":
            return .empty
        case "half_empty":
            return .halfEmpty
        case "full":
            return .full
        default:
            return .notAvailable
        }
    }

    func mapToPrediction(route: Route?) -> Prediction? {
        guard let vehicleId = vehicleId,
            let routeId = routeId,
            let destination = destination,
            let routeDirection = routeDirection,
            let arrivalTime = arriveTimeAsDate else {
                return nil
        }

        let title: String
        if let routeTitle = route?.title {
            title = "\(routeTitle) to \(destination) (\(routeDirection.capitalizingOnlyFirstLetter()))"
        } else {
            title = "**\(destination) (\(routeDirection.capitalizingOnlyFirstLetter()))"
        }

        var color: UIColor? = nil
        if let routeColor = route?.color {
            color = UIColor(hex: routeColor)
        }

        return Prediction(vehicleId: vehicleId,
                          routeId: routeId,
                          routeTitle: title,
                          arrivalTime: Int(arrivalTime.timeIntervalSinceNow),
                          capacity: capacityType,
                          color: color)
    }
}

struct PredictionsErrorDecodable: Decodable {

    let dataFeed: String?

    let stopId: String?

    let message: String?

    private enum CodingKeys: String, CodingKey {
        case dataFeed = "rtpidatafeed"
        case stopId = "stpid"
        case message = "msg"
    }
}

struct BustimeResponseDecodable: Decodable {

    let predictions: [PredictionDecodable]?

    let errors: [PredictionsErrorDecodable]?

    private enum CodingKeys: String, CodingKey {
        case predictions = "prd"
        case errors = "error"
    }
}

struct GetPredictionsForStopIdResponseDecodable: Decodable {

    let bustimeResponse: BustimeResponseDecodable?

    enum CodingKeys: String, CodingKey {
        case bustimeResponse = "bustime-response"
    }
}
