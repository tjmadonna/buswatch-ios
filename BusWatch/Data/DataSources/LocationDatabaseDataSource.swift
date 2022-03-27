//
//  LocationDatabaseDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol LocationDatabaseDataSource {

    func getLastLocationBounds() -> AnyPublisher<LocationBounds, Error>

    func saveLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Error>
}
