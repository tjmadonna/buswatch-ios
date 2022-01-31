//
//  FilterRoutesGetRoutesForStopId.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class FilterRoutesGetRoutesForStopId {

    private let routeRepository: FilterRoutesRouteRepository

    init(routeRepository: FilterRoutesRouteRepository) {
        self.routeRepository = routeRepository
    }

    func execute(stopId: String) -> AnyPublisher<[FilterRoutesRoute], Error> {
        return routeRepository.getRoutesForStopId(stopId)
    }
}
