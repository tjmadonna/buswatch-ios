//
//  DbDetailedStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct DbDetailedStop {
    let id: String
    let title: String
    let serviceType: ServiceType
    let latitude: Double
    let longitude: Double
    let routes: [String]
    let excludedRoutes: [String]
}

extension DbDetailedStop {

    func toDetailedStop() -> DetailedStop {
        let excludedRouteIds = Set(self.excludedRoutes)

        return DetailedStop(
            id: id,
            title: title,
            serviceType: serviceType,
            latitude: latitude,
            longitude: longitude,
            filteredRoutes: routes.filter { id in !excludedRouteIds.contains(id) }
        )
    }

}

extension DbDetailedStop: FetchableRecord {

    init(row: Row) {
        let id = row[StopsTable.idColumn] as String
        let title = row[StopsTable.titleColumn] as String
        let serviceType = row[StopsTable.serviceTypeColumn] as Int
        let latitude = row[StopsTable.latitudeColumn] as Double
        let longitude = row[StopsTable.longitudeColumn] as Double
        let routes = row[StopsTable.routesColumn] as String
        let excludedRoutes = row[ExcludedRoutesTable.routesColumnAlt] as? String

        self.init(
            id: id,
            title: title,
            serviceType: serviceType == 0 ? .portAuthorityBus : .lightRail,
            latitude: latitude,
            longitude: longitude,
            routes: routes.components(separatedBy: StopsTable.routesDelimiter),
            excludedRoutes: excludedRoutes?.components(separatedBy: ExcludedRoutesTable.routesDelimiter) ?? []
        )
    }

}
