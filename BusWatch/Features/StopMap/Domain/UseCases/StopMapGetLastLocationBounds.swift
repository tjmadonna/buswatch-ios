//
//  StopMapGetLastLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class StopMapGetLastLocationBounds {

    private let locationRepository: StopMapLocationRepository

    init(locationRepository: StopMapLocationRepository) {
        self.locationRepository = locationRepository
    }

    func execute() -> AnyPublisher<StopMapLocationBounds, Error> {
        return locationRepository.getLastLocationBounds()
    }
}
