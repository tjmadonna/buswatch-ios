//
//  LocationPermissionDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

final class LocationPermissionDataSourceImpl: LocationPermissionDataSource {

    private let locationManager: CLLocationManager

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
    }

    func getCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never> {
        return CurrentLocationPermissionPublisher(locationManager: locationManager)
            .eraseToAnyPublisher()
    }
}
