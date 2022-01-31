//
//  FilterRoutesRouteMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class FilterRoutesRouteMapper {

    func mapDatabaseRowToRoutesArray(_ row: Row?) -> [FilterRoutesRoute]? {
        guard let row = row else { return nil }
        guard let stopRoutes = row["\(StopsTable.tableName)_\(StopsTable.routesColumn)"] as? String else { return nil }

        let excludedRoutesName = "\(ExcludedRoutesTable.tableName)_\(ExcludedRoutesTable.routesColumn)"
        let excludedRoutes = row[excludedRoutesName] as? String ?? ""

        let routesArray = stopRoutes.components(separatedBy: StopsTable.routesDelimiter)
        let excludedRoutesSet = Set(excludedRoutes.components(separatedBy: ExcludedRoutesTable.routesDelimiter))

        return routesArray.map { route in
            FilterRoutesRoute(id: route, excluded: excludedRoutesSet.contains(route))
        }
    }
}
