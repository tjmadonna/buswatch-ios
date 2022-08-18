//
//  LocationService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import CoreLocation
import Foundation

protocol LocationService {

    func observeLastLocationBounds() -> AnyPublisher<LocationBounds, Error>
    func saveLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Error>
    func observeCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never>

}

final class LocationServiceImpl: LocationService {

    private let dbDataSource: LocationDbDataSource

    private let locationManager: CLLocationManager

    init(dbDataSource: LocationDbDataSource, locationManager: CLLocationManager = CLLocationManager()) {
        self.dbDataSource = dbDataSource
        self.locationManager = locationManager
    }

    func observeLastLocationBounds() -> AnyPublisher<LocationBounds, Error> {
        return dbDataSource.observeLastLocationBounds()
            .map { locationBounds in locationBounds.toLocationBounds() }
            .eraseToAnyPublisher()
    }

    func saveLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Error> {
        return dbDataSource.insertLastLocationBounds(locationBounds)
            .eraseToAnyPublisher()
    }

    func observeCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never> {
        return CurrentLocationPermissionPublisher(locationManager: locationManager)
            .eraseToAnyPublisher()
    }

}
