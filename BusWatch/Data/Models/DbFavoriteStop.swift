//
//  DbFavoriteStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct DbFavoriteStop {
    let id: String
    let title: String
    let serviceType: ServiceType
    let routes: [String]
    let excludedRoutes: [String]
}

extension DbFavoriteStop {

    func toFavoriteStop() -> FavoriteStop {
        let excludedRouteIds = Set(self.excludedRoutes)

        return FavoriteStop(
            id: id,
            title: title,
            serviceType: serviceType,
            filteredRoutes: routes.filter { id in !excludedRouteIds.contains(id) }
        )
    }

}

extension DbFavoriteStop: FetchableRecord {

    init(row: Row) {
        let id = row[StopsTable.idColumn] as String
        let title = row[StopsTable.titleColumn] as String
        let serviceType = row[StopsTable.serviceTypeColumn] as Int
        let routes = row[StopsTable.routesColumn] as String
        let excludedRoutes = row[ExcludedRoutesTable.routesColumnAlt] as? String

        self.init(
            id: id,
            title: title,
            serviceType: serviceType == 0 ? .portAuthorityBus : .lightRail,
            routes: routes.components(separatedBy: StopsTable.routesDelimiter),
            excludedRoutes: excludedRoutes?.components(separatedBy: ExcludedRoutesTable.routesDelimiter) ?? []
        )
    }

}
