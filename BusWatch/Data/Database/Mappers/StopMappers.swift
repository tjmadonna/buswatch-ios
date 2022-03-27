//
//  StopMappers.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

extension GRDB.Row {

    func toMinimalStop() -> MinimalStop? {
        guard let id = self[StopsTable.idColumn] as? String else { return nil }
        guard let title = self[StopsTable.titleColumn] as? String else { return nil }
        guard let favorite = self[StopsTable.favoriteColumn] as? Int else { return nil }

        return MinimalStop(
            id: id,
            title: title,
            favorite: favorite > 0
        )
    }

    func toDatabaseDetailedStop() -> DatabaseDetailedStop? {
        guard let id = self[StopsTable.idColumn] as? String else { return nil }
        guard let title = self[StopsTable.titleColumn] as? String else { return nil }
        guard let latitude = self[StopsTable.latitudeColumn] as? Double else { return nil }
        guard let longitude = self[StopsTable.longitudeColumn] as? Double else { return nil }

        let routesString = self[StopsTable.routesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTable.routesDelimiter)

        let excludedRoutesString = self[StopsTable.excludedRoutesColumn] as? String ?? ""
        let excludedRoutes = excludedRoutesString.components(separatedBy: StopsTable.routesDelimiter)

        return DatabaseDetailedStop(
            id: id,
            title: title,
            latitude: latitude,
            longitude: longitude,
            routes: routes,
            excludedRoutes: excludedRoutes
        )
    }

    func toDatabaseFavoriteStop() -> DatabaseFavoriteStop? {
        guard let id = self[StopsTable.idColumn] as? String else { return nil }
        guard let title = self[StopsTable.titleColumn] as? String else { return nil }

        let routesString = self[StopsTable.routesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTable.routesDelimiter)

        let excludedRoutesString = self[StopsTable.excludedRoutesColumn] as? String ?? ""
        let excludedRoutes = excludedRoutesString.components(separatedBy: StopsTable.routesDelimiter)

        return DatabaseFavoriteStop(
            id: id,
            title: title,
            routes: routes,
            excludedRoutes: excludedRoutes
        )
    }
}
