//
//  UpdateExcludedRoutes.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class UpdateExcludedRoutes {

    private let routeRepository: RouteRepositoryRepresentable

    public init(routeRepository: RouteRepositoryRepresentable) {
        self.routeRepository = routeRepository
    }

    func execute(routeIds: [String], stopId: String) -> AnyPublisher<Void, Error> {
        return routeRepository.updateExcludedRoutes(routeIds, stopId: stopId)
    }
}
