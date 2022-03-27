//
//  DatabaseDetailedStopMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/27/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

extension DatabaseDetailedStop {

    func toDetailedStop() -> DetailedStop {
        let excludedRouteIds = Set(self.excludedRoutes)

        return DetailedStop(
            id: self.id,
            title: self.title,
            latitude: self.latitude,
            longitude: self.longitude,
            filteredRoutes: self.routes.filter { !excludedRouteIds.contains($0) }
        )
    }
}
