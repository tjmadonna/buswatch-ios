//
//  LocationRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class LocationRepositoryImpl: LocationRepository {

    private let database: LocationDatabaseDataSource

    private let permissions: LocationPermissionDataSource

    init(database: LocationDatabaseDataSource, permissions: LocationPermissionDataSource) {
        self.database = database
        self.permissions = permissions
    }

    func getLastLocationBounds() -> AnyPublisher<LocationBounds, Error> {
        return database.getLastLocationBounds()
    }

    func saveLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Error> {
        return database.saveLastLocationBounds(locationBounds)
    }

    func getCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never> {
        return permissions.getCurrentLocationPermissionStatus()
    }
}
