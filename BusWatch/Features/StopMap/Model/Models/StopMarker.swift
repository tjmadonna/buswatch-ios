//
//  StopMarker.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import CoreLocation
import Foundation
import GRDB

// MARK: - Database models
struct StopMarker {
    let id: String
    let title: String
    let serviceType: ServiceType
    let coordinate: CLLocationCoordinate2D
    let routes: [String]
}

extension StopMarker: Identifiable {

}

extension StopMarker: Equatable {

    static func == (lhs: StopMarker, rhs: StopMarker) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.serviceType == rhs.serviceType &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude &&
            lhs.routes == rhs.routes
    }

}

extension StopMarker: GRDB.FetchableRecord  {

    init(row: GRDB.Row) {
        let id = row[StopsTable.idColumn] as String
        let title = row[StopsTable.titleColumn] as String
        let serviceType = row[StopsTable.serviceTypeColumn] as Int
        let latitude = row[StopsTable.latitudeColumn] as Double
        let longitude = row[StopsTable.longitudeColumn] as Double
        let routesStr = row[StopsTable.routesColumn] as String
        let routes = routesStr.components(separatedBy: StopsTable.routesDelimiter)
        let excludedRoutesStr = row["excluded_routes"] as String?
        let excludedRoutes = excludedRoutesStr?.components(separatedBy: ExcludedRoutesTable.routesDelimiter) ?? []

        let excludedRoutesSet = Set(excludedRoutes)

        self.init(
            id: id,
            title: title,
            serviceType: serviceType == 0 ? .portAuthorityBus : .lightRail,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            routes: routes.filter { !excludedRoutesSet.contains($0) }
        )
    }

}
