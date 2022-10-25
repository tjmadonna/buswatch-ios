//
//  FilterRouteWithExclusions.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct FilterRouteWithExclusions {
    let routes: [String]
    let excludedRoutes: [String]
}

extension FilterRouteWithExclusions: GRDB.FetchableRecord {

    init(row: Row) {
        let routes = row[StopsTable.routesColumn] as String
        let excludedRoutes = row[ExcludedRoutesTable.routesColumnAlt] as? String

        self.init(
            routes: routes.components(separatedBy: StopsTable.routesDelimiter),
            excludedRoutes: excludedRoutes?.components(separatedBy: ExcludedRoutesTable.routesDelimiter) ?? []
        )
    }

}
