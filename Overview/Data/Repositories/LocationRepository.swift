//
//  LocationRepository.swift
//  Overview
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class LocationRepository: LocationRepositoryRepresentable {

    private let locationDataSource: LocationDataSourceRepresentable

    public init(locationDataSource: LocationDataSourceRepresentable) {
        self.locationDataSource = locationDataSource
    }

    // MARK: - LocationRepositoryRepresentable

    public func getLastLocationBounds() -> AnyPublisher<LocationBounds, Error> {
        return locationDataSource.getLastLocationBounds()
    }
}
