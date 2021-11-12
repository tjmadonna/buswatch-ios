//
//  LocationPermissionDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

public final class LocationPermissionDataSource: LocationPermissionDataSourceRepresentable {

    private let locationManager: CLLocationManager

    public init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    // MARK: - LocationPermissionDataSourceRepresentable

    public func getCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never> {
        return LocationPermissionPublisher(locationManager: locationManager)
            .eraseToAnyPublisher()
    }
}
