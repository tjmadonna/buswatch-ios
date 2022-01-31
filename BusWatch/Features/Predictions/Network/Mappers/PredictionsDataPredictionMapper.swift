//
//  PredictionsDataPredictionMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

final class PredictionsDataPredictionMapper {

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyyMMdd HH:mm"
        return dateFormatter
    }()

    func mapNetworkPredictionArrayToDataPredictionArray(_ networkPredictions: [PredictionsNetworkPrediction]?)
        -> [PredictionsDataPrediction]? {

        guard let networkPredictions = networkPredictions else { return nil }
        let dataPredictions = networkPredictions.compactMap { mapNetworkPredictionToDataPrediction($0) }

        if dataPredictions.isEmpty {
            return nil
        } else {
            return dataPredictions
        }
    }

    func mapNetworkPredictionToDataPrediction(_ networkPrediction: PredictionsNetworkPrediction?)
        -> PredictionsDataPrediction? {

        guard let networkPrediction = networkPrediction else { return nil }
        guard let vehicleId = networkPrediction.vehicleId else { return nil }
        guard let routeId = networkPrediction.routeId else { return nil }
        guard let destination = networkPrediction.destination else { return nil }
        guard let routeDirection = networkPrediction.routeDirection else { return nil }
        guard let arrivalTime = mapArrivalTimeToDate(networkPrediction.arrivalTime) else { return nil }
        let capacity = mapCapacityStringToCapacity(networkPrediction.capacity)

        return PredictionsDataPrediction(
            vehicleId: vehicleId,
            routeId: routeId,
            destination: destination,
            routeDirection: routeDirection.capitalizingOnlyFirstLetter(),
            arrivalTime: arrivalTime,
            capacity: capacity
        )
    }

    private func mapArrivalTimeToDate(_ arrivalTime: String?) -> Date? {
        guard let arrivalTime = arrivalTime else { return nil }
        return self.dateFormatter.date(from: arrivalTime)
    }

    private func mapCapacityStringToCapacity(_ capacityString: String?) -> PredictionsCapacityType {
        switch capacityString?.lowercased() {
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
}
