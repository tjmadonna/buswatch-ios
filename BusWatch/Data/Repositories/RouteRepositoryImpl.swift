//
//  RouteRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class RouteRepositoryImpl: RouteRepository {

    private let database: RouteDatabaseDataSource

    init(database: RouteDatabaseDataSource) {
        self.database = database
    }

    func getRoutesForStopId(_ stopId: String) -> AnyPublisher<[ExclusionRoute], Error> {
        return database.getRoutesForStopId(stopId)
            .map { routes in
                routes.sorted { $0.id > $1.id }
            }
            .eraseToAnyPublisher()
    }

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Error> {
        return database.updateExcludedRouteIdsForStopId(stopId, routeIds: routeIds)
    }
}
