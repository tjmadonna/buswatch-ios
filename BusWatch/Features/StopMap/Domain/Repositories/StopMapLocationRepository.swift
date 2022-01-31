//
//  StopMapLocationRepository.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/26/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol StopMapLocationRepository {

    func getLastLocationBounds() -> AnyPublisher<StopMapLocationBounds, Error>

    func saveLastLocationBounds(_ locationBounds: StopMapLocationBounds) -> AnyPublisher<Void, Error>

    func getCurrentLocationPermissionStatus() -> AnyPublisher<StopMapCurrentLocationPermissionStatus, Never>

}
