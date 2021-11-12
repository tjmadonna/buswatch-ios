//
//  LocationRepositoryRepresentable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/26/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public protocol LocationRepositoryRepresentable {

    func getLastLocationBounds() -> AnyPublisher<LocationBounds, Error>

    func saveLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Error>

    func getCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never>

}
