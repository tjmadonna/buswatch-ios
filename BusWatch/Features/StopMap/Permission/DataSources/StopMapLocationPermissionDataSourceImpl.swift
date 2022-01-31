//
//  StopMapLocationPermissionDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

final class StopMapLocationPermissionDataSourceImpl: StopMapLocationPermissionDataSource {

    private let locationManager: CLLocationManager

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    // MARK: - StopMapLocationPermissionDataSource

    func getCurrentLocationPermissionStatus() -> AnyPublisher<StopMapCurrentLocationPermissionStatus, Never> {
        return StopMapLocationPermissionPublisher(locationManager: locationManager)
            .eraseToAnyPublisher()
    }
}
