//
//  DataPredictionMapper.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

public final class DataPredictionMapper {

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyyMMdd HH:mm"
        return dateFormatter
    }()

    public init() { }

    func mapNetworkPredictionArrayToDataPredictionArray(_ networkPredictions: [NetworkPrediction]?) -> [DataPrediction]? {
        guard let networkPredictions = networkPredictions else { return nil }
        let dataPredictions = networkPredictions.compactMap { mapNetworkPredictionToDataPrediction($0) }

        if dataPredictions.isEmpty {
            return nil
        } else {
            return dataPredictions
        }
    }

    func mapNetworkPredictionToDataPrediction(_ networkPrediction: NetworkPrediction?) -> DataPrediction? {
        guard let networkPrediction = networkPrediction else { return nil }
        guard let vehicleId = networkPrediction.vehicleId else { return nil }
        guard let routeId = networkPrediction.routeId else { return nil }
        guard let destination = networkPrediction.destination else { return nil }
        guard let routeDirection = networkPrediction.routeDirection else { return nil }
        guard let arrivalTime = mapArrivalTimeToDate(networkPrediction.arrivalTime) else { return nil }
        let capacity = mapCapacityStringToCapacity(networkPrediction.capacity)

        return DataPrediction(
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

    private func mapCapacityStringToCapacity(_ capacityString: String?) -> CapacityType {
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





//    func mapDatabaseCursorToDataRouteArray(_ cursor: RowCursor) -> [DataRoute] {
//        var routes = [DataRoute]()
//        while let cursorRow = try? cursor.next() {
//            if let route = mapDatabaseRowToDataRoute(cursorRow) {
//                routes.append(route)
//            }
//        }
//        return routes
//    }
//
//    func mapDatabaseRowToDataRoute(_ row: Row?) -> DataRoute? {
//        guard let row = row else { return nil }
//        guard let id = row[RoutesTable.idColumn] as? String else { return nil }
//        guard let title = row[RoutesTable.titleColumn] as? String else { return nil }
//        guard let color = row[RoutesTable.colorColumn] as? String else { return nil }
//
//        return DataRoute(
//            id: id,
//            title: title,
//            color: color
//        )
//    }
}
