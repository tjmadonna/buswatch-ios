//
//  OverviewFavoriteStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

// MARK: - Database models
struct OverviewFavoriteStop {
    let id: String
    let title: String
    let serviceType: ServiceType
    let routes: [String]
}

extension OverviewFavoriteStop: GRDB.FetchableRecord  {

    init(row: GRDB.Row) {
        let id = row[StopsTable.idColumn] as String
        let title = row[StopsTable.titleColumn] as String
        let serviceType = row[StopsTable.serviceTypeColumn] as Int
        let routesStr = row[StopsTable.routesColumn] as String
        let excludedRoutesStr = row["excluded_routes"] as? String

        // Filter routes based on the user selected excluded routes
        let routes = routesStr.components(separatedBy: StopsTable.routesDelimiter)
        let excludedRoutes = excludedRoutesStr?.components(separatedBy: ExcludedRoutesTable.routesDelimiter) ?? []
        let excludedRoutesSet = Set(excludedRoutes)

        self.init(
            id: id,
            title: title,
            serviceType: serviceType == 0 ? .portAuthorityBus : .lightRail,
            routes: routes.filter { route in !excludedRoutesSet.contains(route) }
        )
    }

}
