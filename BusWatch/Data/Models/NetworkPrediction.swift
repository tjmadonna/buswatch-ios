//
//  NetworkPrediction.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

struct NetworkPrediction: Decodable {

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

}

extension NetworkPrediction {

    func toPrediction(route: DbRoute?, dateFormatter: DateFormatter) -> Prediction? {
        guard let vehicleId = self.vehicleId else { return nil }
        guard let routeId = self.routeId else { return nil }
        guard let destination = self.destination?.capitalizingOnlyFirstLetters() else { return nil }
        guard let routeDirection = self.routeDirection?.capitalizingOnlyFirstLetters() else { return nil }
        guard let arrivalTimeStr = arrivalTime else { return nil }
        guard let arrivalTime = dateFormatter.date(from: arrivalTimeStr) else { return nil }

        let capacity = getCapacityType(self.capacity)

        let title: String
        if let routeTitle = route?.title {
            title = Resources.Strings.predictionTitleWithRoute(routeTitle, destination, routeDirection)
        } else {
            title = Resources.Strings.predictionTitleNoRoute(destination, routeDirection)
        }

        return Prediction(
            id: vehicleId,
            title: title,
            route: routeId,
            capacity: capacity,
            arrivalInSeconds: Int(arrivalTime.timeIntervalSinceNow)
        )
    }

    private func getCapacityType(_ capacityString: String?) -> Capacity? {
        switch capacityString?.lowercased() {
        case "empty":
            return .empty
        case "half_empty":
            return .halfEmpty
        case "full":
            return .full
        default:
            return nil
        }
    }
}

struct NetworkPredictionError: Decodable {

    let dataFeed: String?

    let stopId: String?

    let message: String?

    private enum CodingKeys: String, CodingKey {
        case dataFeed = "rtpidatafeed"
        case stopId = "stpid"
        case message = "msg"
    }
}

struct NetworkBustimeResponse: Decodable {

    let predictions: [NetworkPrediction]?

    let errors: [NetworkPredictionError]?

    private enum CodingKeys: String, CodingKey {
        case predictions = "prd"
        case errors = "error"
    }
}

struct NetworkGetPredictionsResponse: Decodable {

    let bustimeResponse: NetworkBustimeResponse?

    enum CodingKeys: String, CodingKey {
        case bustimeResponse = "bustime-response"
    }
}
