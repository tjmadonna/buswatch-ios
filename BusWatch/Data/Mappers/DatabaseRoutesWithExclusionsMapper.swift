//
//  DatabaseRoutesWithExclusionsMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/27/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

extension DatabaseRoutesWithExclusions {

    func toFilterableRoutes() -> [FilterableRoute] {
        let excludedRouteIds = Set(self.excludedRoutes)

        return self.routes.map { routeId in
            FilterableRoute(
                id: routeId,
                filtered: excludedRouteIds.contains(routeId)
            )
        }
    }
}
