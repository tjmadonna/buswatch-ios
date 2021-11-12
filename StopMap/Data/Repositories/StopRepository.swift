//
//  StopRepository.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/26/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class StopRepository: StopRepositoryRepresentable {

    private let stopDataSource: StopDataSourceRepresentable

    public init(stopDataSource: StopDataSourceRepresentable) {
        self.stopDataSource = stopDataSource
    }

    // MARK: - StopRepositoryRepresentable

    public func getStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[Stop], Error> {
        return stopDataSource.getStopsInLocationBounds(locationBounds)
    }
}
