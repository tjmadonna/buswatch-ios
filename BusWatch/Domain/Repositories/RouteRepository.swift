//
//  RouteRepository.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol RouteRepository {

    func getFilterableRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterableRoute], Error>

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Error>

}
