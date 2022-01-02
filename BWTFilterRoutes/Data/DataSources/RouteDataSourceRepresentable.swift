//
//  RouteDataSourceRepresentable.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public protocol RouteDataSourceRepresentable {

    func getRoutesForStopId(_ stopId: String) -> AnyPublisher<[Route], Error>

    func updateExcludedRoutes(_ routeIds: [String], stopId: String) -> AnyPublisher<Void, Error>

}
