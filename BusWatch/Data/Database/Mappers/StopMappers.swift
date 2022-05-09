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

        return MinimalStop(
            id: id,
            title: title,
            favorite: self[FavoriteStopsTable.stopIdColumn] != nil
        )
    }

    func toDatabaseDetailedStop() -> DatabaseDetailedStop? {
        guard let id = self[StopsTable.idColumn] as? String else { return nil }
        guard let title = self[StopsTable.titleColumn] as? String else { return nil }
        guard let serviceType = self[StopsTable.serviceTypeColumn] as? Int64 else { return nil }
        guard let latitude = self[StopsTable.latitudeColumn] as? Double else { return nil }
        guard let longitude = self[StopsTable.longitudeColumn] as? Double else { return nil }

        let routesString = self[StopsTable.routesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTable.routesDelimiter)

        let excludedRoutesString = self[ExcludedRoutesTable.routesColumnAlt] as? String ?? ""
        let excludedRoutes = excludedRoutesString.components(separatedBy: ExcludedRoutesTable.routesDelimiter)

        return DatabaseDetailedStop(
            id: id,
            title: title,
            serviceType: serviceType == StopsTable.lightRailServiceType ? .lightRail : .portAuthorityBus,
            latitude: latitude,
            longitude: longitude,
            routes: routes,
            excludedRoutes: excludedRoutes
        )
    }

    func toDatabaseFavoriteStop() -> DatabaseFavoriteStop? {
        guard let id = self[StopsTable.idColumn] as? String else { return nil }
        guard let title = self[StopsTable.titleColumn] as? String else { return nil }
        guard let serviceType = self[StopsTable.serviceTypeColumn] as? Int64 else { return nil }

        let routesString = self[StopsTable.routesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTable.routesDelimiter)

        let excludedRoutesString = self[ExcludedRoutesTable.routesColumnAlt] as? String ?? ""
        let excludedRoutes = excludedRoutesString.components(separatedBy: ExcludedRoutesTable.routesDelimiter)

        return DatabaseFavoriteStop(
            id: id,
            title: title,
            serviceType: serviceType == StopsTable.lightRailServiceType ? .lightRail : .portAuthorityBus,
            routes: routes,
            excludedRoutes: excludedRoutes
        )
    }
}
