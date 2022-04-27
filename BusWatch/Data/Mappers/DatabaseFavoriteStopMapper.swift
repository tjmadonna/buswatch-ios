//
//  DatabaseFavoriteStopMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/27/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

extension DatabaseFavoriteStop {

    func toFavoriteStop() -> FavoriteStop {
        let excludedRouteIds = Set(self.excludedRoutes)

        return FavoriteStop(
            id: self.id,
            title: self.title,
            serviceType: self.serviceType,
            filteredRoutes: self.routes.filter { !excludedRouteIds.contains($0) }
        )
    }
}
