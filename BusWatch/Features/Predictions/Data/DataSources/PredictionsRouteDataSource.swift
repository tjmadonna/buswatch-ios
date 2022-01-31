//
//  PredictionsRouteDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol PredictionsRouteDataSource {

    func getRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[PredictionsDataRoute], Error>

    func getExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Error>
}
