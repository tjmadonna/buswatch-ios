//
//  SaveLastLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/26/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class SaveLastLocationBounds {

    private let locationRepository: LocationRepositoryRepresentable

    public init(locationRepository: LocationRepositoryRepresentable) {
        self.locationRepository = locationRepository
    }

    func execute(locationBounds: LocationBounds) -> AnyPublisher<Void, Error> {
        return locationRepository.saveLastLocationBounds(locationBounds)
    }
}
