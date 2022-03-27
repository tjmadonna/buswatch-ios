//
//  PredictionMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

extension NetworkPrediction {

    func toPrediction(route: DatabaseRoute?, dateFormatter: DateFormatter) -> Prediction? {
        guard let vehicleId = self.vehicleId else { return nil }
        guard let routeId = self.routeId else { return nil }
        guard let destination = self.destination else { return nil }
        guard let routeDirection = self.routeDirection?.capitalizingOnlyFirstLetter() else { return nil }

        guard let arrivalTime = arrivalTime else { return nil }
        guard let arrivalTimeDate = dateFormatter.date(from: arrivalTime) else { return nil }

        let title: String
        if let routeTitle = route?.title {
            title = Resources.Strings.predictionTitleWithRoute(routeTitle, destination, routeDirection)
        } else {
            title = Resources.Strings.predictionTitleNoRoute(destination, routeDirection)
        }

        let capacityImageName: String?
        switch self.capacity?.lowercased() {
        case "empty":
            capacityImageName = Resources.Images.capacityEmpty
        case "half_empty":
            capacityImageName = Resources.Images.capacityHalfEmpty
        case "full":
            capacityImageName = Resources.Images.capacityFull
        default:
            capacityImageName = nil
        }

        let seconds = Int(arrivalTimeDate.timeIntervalSinceNow)
        let arrivalMessage: String
        switch seconds {
        case Int.min...30:
            arrivalMessage = Resources.Strings.arrivingNow
        case 30..<120:
            arrivalMessage = Resources.Strings.arrivingIn1Min
        default:
            arrivalMessage = Resources.Strings.arrivingInNMins(Int(seconds / 60))
        }

        return Prediction(
            id: vehicleId,
            title: title,
            route: routeId,
            capacityImageName: capacityImageName,
            arrivalMessage: arrivalMessage
        )
    }
}
