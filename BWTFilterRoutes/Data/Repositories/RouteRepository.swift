//
//  RouteRepository.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class RouteRepository : RouteRepositoryRepresentable {

    private let routeDataSource: RouteDataSourceRepresentable

    public init(routeDataSource: RouteDataSourceRepresentable) {
        self.routeDataSource = routeDataSource
    }

    public func getRoutesForStopId(_ stopId: String) -> AnyPublisher<[Route], Error> {
        return routeDataSource.getRoutesForStopId(stopId)
    }

    public func updateExcludedRoutes(_ routeIds: [String], stopId: String) -> AnyPublisher<Void, Error> {
        return routeDataSource.updateExcludedRoutes(routeIds, stopId: stopId)
    }
}
