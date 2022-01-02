//
//  GetRoutesForStopId.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class GetRoutesForStopId {

    private let routeRepository: RouteRepositoryRepresentable

    public init(routeRepository: RouteRepositoryRepresentable) {
        self.routeRepository = routeRepository
    }

    func execute(stopId: String) -> AnyPublisher<[Route], Error> {
        return routeRepository.getRoutesForStopId(stopId)
    }
}
