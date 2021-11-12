//
//  LocationRepository.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class LocationRepository: LocationRepositoryRepresentable {

    private let locationDataSource: LocationDataSourceRepresentable

    private let locationPermissionDataSource: LocationPermissionDataSourceRepresentable

    public init(locationDataSource: LocationDataSourceRepresentable,
                locationPermissionDataSource: LocationPermissionDataSourceRepresentable) {
        self.locationDataSource = locationDataSource
        self.locationPermissionDataSource = locationPermissionDataSource
    }

    // MARK: - LocationRepositoryRepresentable

    public func getLastLocationBounds() -> AnyPublisher<LocationBounds, Error> {
        return locationDataSource.getLastLocationBounds()
    }

    public func saveLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Error> {
        return locationDataSource.saveLastLocationBounds(locationBounds)
    }

    public func getCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never> {
        return locationPermissionDataSource.getCurrentLocationPermissionStatus()
    }
}
