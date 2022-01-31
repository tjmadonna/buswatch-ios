//
//  StopMapSaveLastLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/26/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class StopMapSaveLastLocationBounds {

    private let locationRepository: StopMapLocationRepository

    init(locationRepository: StopMapLocationRepository) {
        self.locationRepository = locationRepository
    }

    func execute(locationBounds: StopMapLocationBounds) -> AnyPublisher<Void, Error> {
        return locationRepository.saveLastLocationBounds(locationBounds)
    }
}
