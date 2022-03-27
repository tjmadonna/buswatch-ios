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

    func toFilteredRouteIds() -> [String] {
        guard let routeIdString = self[ExcludedRoutesTable.routesColumn] as? String else { return [] }
        return routeIdString.components(separatedBy: ExcludedRoutesTable.routesDelimiter)
    }

    func toFilterableRoute() -> [FilterableRoute] {
        guard let stopRoutes = self["\(StopsTable.tableName)_\(StopsTable.routesColumn)"] as? String else { return [] }
        let exRoutes = self["\(ExcludedRoutesTable.tableName)_\(ExcludedRoutesTable.routesColumn)"] as? String ?? ""

        let routesArray = stopRoutes.components(separatedBy: StopsTable.routesDelimiter)
        let excludedRoutesSet = Set(exRoutes.components(separatedBy: ExcludedRoutesTable.routesDelimiter))

        return routesArray.map { route in
            FilterableRoute(id: route,
                            filtered: excludedRoutesSet.contains(route))
        }
    }
}
