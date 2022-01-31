//
//  StopMapStopRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/26/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class StopMapStopRepositoryImpl: StopMapStopRepository {

    private let stopDataSource: StopMapStopDataSource

    init(stopDataSource: StopMapStopDataSource) {
        self.stopDataSource = stopDataSource
    }

    // MARK: - StopMapStopRepository

    func getStopsInLocationBounds(_ locationBounds: StopMapLocationBounds) -> AnyPublisher<[StopMapStop], Error> {
        return stopDataSource.getStopsInLocationBounds(locationBounds)
    }
}
