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

    func getFilterableRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterableRoute], Error>

    func getRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[DatabaseRoute], Error>

    func getFilteredRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Error>

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Error>

}
