//
//  RouteMappers.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

extension GRDB.Row {

    func toDatabaseRoute() -> DatabaseRoute? {
        guard let id = self[RoutesTable.idColumn] as? String else { return nil }
        guard let title = self[RoutesTable.titleColumn] as? String else { return nil }

        return DatabaseRoute(
            id: id,
            title: title
        )
    }

    func toExcludedRouteIds() -> [String] {
        guard let routeIdString = self[StopsTable.excludedRoutesColumn] as? String else { return [] }
        return routeIdString.components(separatedBy: StopsTable.routesDelimiter)
    }

    func toDatabaseRoutesWithExclusions() -> DatabaseRoutesWithExclusions? {
        let routesString = self[StopsTable.routesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTable.routesDelimiter)

        let excludedRoutesString = self[StopsTable.excludedRoutesColumn] as? String ?? ""
        let excludedRoutes = excludedRoutesString.components(separatedBy: StopsTable.routesDelimiter)

        return DatabaseRoutesWithExclusions(
            routes: routes,
            excludedRoutes: excludedRoutes
        )
    }
}
