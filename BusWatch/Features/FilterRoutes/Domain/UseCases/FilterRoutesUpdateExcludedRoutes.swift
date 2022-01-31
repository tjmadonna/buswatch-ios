//
//  FilterRoutesUpdateExcludedRoutes.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class FilterRoutesUpdateExcludedRoutes {

    private let routeRepository: FilterRoutesRouteRepository

    init(routeRepository: FilterRoutesRouteRepository) {
        self.routeRepository = routeRepository
    }

    func execute(routeIds: [String], stopId: String) -> AnyPublisher<Void, Error> {
        return routeRepository.updateExcludedRoutes(routeIds, stopId: stopId)
    }
}
