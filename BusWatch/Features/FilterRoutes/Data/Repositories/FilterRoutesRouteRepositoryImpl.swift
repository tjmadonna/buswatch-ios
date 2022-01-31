//
//  FilterRoutesRouteRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class FilterRoutesRouteRepositoryImpl: FilterRoutesRouteRepository {

    private let routeDataSource: FilterRoutesRouteDataSource

    init(routeDataSource: FilterRoutesRouteDataSource) {
        self.routeDataSource = routeDataSource
    }

    // MARK: - FilterRoutesRouteRepository

    func getRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterRoutesRoute], Error> {
        return routeDataSource.getRoutesForStopId(stopId)
    }

    func updateExcludedRoutes(_ routeIds: [String], stopId: String) -> AnyPublisher<Void, Error> {
        return routeDataSource.updateExcludedRoutes(routeIds, stopId: stopId)
    }
}
