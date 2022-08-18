//
//  RouteService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol RouteService {

    func observeFilterableRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterableRoute], Error>
    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Error>
    func observeExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Error>

}

final class RouteServiceImpl: RouteService {

    private let dbDataSource: RouteDbDataSource

    init(dbDataSource: RouteDbDataSource) {
        self.dbDataSource = dbDataSource
    }

    func observeFilterableRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterableRoute], Error> {
        return dbDataSource.observeDbRoutesWithExcludedForStopId(stopId)
            .map { routes in routes.toFilterableRoutes() }
            .eraseToAnyPublisher()
    }

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Error> {
        return dbDataSource.updateExcludedRouteIdsForStopId(stopId, routeIds: routeIds)
    }

    func observeExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Error> {
        return dbDataSource.observeExcludedRouteIdsForStopId(stopId)
    }

}
