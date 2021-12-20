//
//  GetLastLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class GetLastLocationBounds {

    private let locationRepository: LocationRepositoryRepresentable

    public init(locationRepository: LocationRepositoryRepresentable) {
        self.locationRepository = locationRepository
    }

    func execute() -> AnyPublisher<LocationBounds, Error> {
        return locationRepository.getLastLocationBounds()
    }
}
