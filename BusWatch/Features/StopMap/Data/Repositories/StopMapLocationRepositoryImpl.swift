//
//  StopMapLocationRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class StopMapLocationRepositoryImpl: StopMapLocationRepository {

    private let locationDataSource: StopMapLocationDataSource

    private let locationPermissionDataSource: StopMapLocationPermissionDataSource

    init(locationDataSource: StopMapLocationDataSource,
         locationPermissionDataSource: StopMapLocationPermissionDataSource) {
        self.locationDataSource = locationDataSource
        self.locationPermissionDataSource = locationPermissionDataSource
    }

    // MARK: - StopMapLocationRepository

    func getLastLocationBounds() -> AnyPublisher<StopMapLocationBounds, Error> {
        return locationDataSource.getLastLocationBounds()
    }

    func saveLastLocationBounds(_ locationBounds: StopMapLocationBounds) -> AnyPublisher<Void, Error> {
        return locationDataSource.saveLastLocationBounds(locationBounds)
    }

    func getCurrentLocationPermissionStatus() -> AnyPublisher<StopMapCurrentLocationPermissionStatus, Never> {
        return locationPermissionDataSource.getCurrentLocationPermissionStatus()
    }
}
