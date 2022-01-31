//
//  GetLastLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class OverviewGetLastLocationBounds {

    private let locationRepository: OverviewLocationRepository

    init(locationRepository: OverviewLocationRepository) {
        self.locationRepository = locationRepository
    }

    func execute() -> AnyPublisher<OverviewLocationBounds, Error> {
        return locationRepository.getLastLocationBounds()
    }
}
