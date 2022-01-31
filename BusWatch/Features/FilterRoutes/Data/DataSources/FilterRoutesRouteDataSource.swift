//
//  FilterRoutesRouteDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol FilterRoutesRouteDataSource {

    func getRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterRoutesRoute], Error>

    func updateExcludedRoutes(_ routeIds: [String], stopId: String) -> AnyPublisher<Void, Error>

}
