//
//  RouteMapper.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB
import BWTDatabase

public final class RouteMapper {

    public init() { }

    func mapDatabaseRowToRoutesArray(_ row: Row?) -> [Route]? {
        guard let row = row else { return nil }
        guard let stopRoutes = row["\(StopsTable.tableName)_\(StopsTable.routesColumn)"] as? String else { return nil }
        let excludedRoutes = row["\(ExcludedRoutesTable.tableName)_\(ExcludedRoutesTable.routesColumn)"] as? String ?? ""

        let routesArray = stopRoutes.components(separatedBy: StopsTable.routesDelimiter)
        let excludedRoutesSet = Set(excludedRoutes.components(separatedBy: ExcludedRoutesTable.routesDelimiter))

        return routesArray.map { route in
            Route(id: route, excluded: excludedRoutesSet.contains(route))
        }
    }
}
