//
//  RouteDataSourceRepresentable.swift
//  Predictions
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public protocol RouteDataSourceRepresentable {

    func getRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[DataRoute], Error>

    func getExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Error>
}
