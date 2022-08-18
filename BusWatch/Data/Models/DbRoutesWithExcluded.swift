//
//  DbRoutesWithExcluded.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct DbRoutesWithExcluded {
    let routes: [String]
    let excludedRoutes: [String]
}

extension DbRoutesWithExcluded {

    func toFilterableRoutes() -> [FilterableRoute] {
        let excludedRouteIds = Set(excludedRoutes)

        return self.routes.map { routeId in
            FilterableRoute(
                id: routeId,
                filtered: excludedRouteIds.contains(routeId)
            )
        }
    }

}

extension DbRoutesWithExcluded: FetchableRecord {

    init(row: Row) {
        let routes = row[StopsTable.routesColumn] as String
        let excludedRoutes = row[ExcludedRoutesTable.routesColumnAlt] as? String

        self.init(
            routes: routes.components(separatedBy: StopsTable.routesDelimiter),
            excludedRoutes: excludedRoutes?.components(separatedBy: ExcludedRoutesTable.routesDelimiter) ?? []
        )
    }

}
