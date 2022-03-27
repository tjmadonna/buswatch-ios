//
//  RouteDatabaseDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol RouteDatabaseDataSource {

    func getDatabaseRoutesWithExclusionsForStopId(_ stopId: String)
        -> AnyPublisher<DatabaseRoutesWithExclusions, Error>

    func getRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[DatabaseRoute], Error>

    func getExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Error>

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Error>

}
