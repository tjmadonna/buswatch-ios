//
//  OverviewLocationRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class OverviewLocationRepositoryImpl: OverviewLocationRepository {

    private let locationDataSource: OverviewLocationDataSource

    init(locationDataSource: OverviewLocationDataSource) {
        self.locationDataSource = locationDataSource
    }

    // MARK: - OverviewLocationRepository

    func getLastLocationBounds() -> AnyPublisher<OverviewLocationBounds, Error> {
        return locationDataSource.getLastLocationBounds()
    }
}
