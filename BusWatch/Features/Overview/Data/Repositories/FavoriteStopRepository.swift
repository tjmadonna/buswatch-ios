//
//  OverviewFavoriteStopRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class OverviewStopRepositoryImpl: OverviewStopRepository {

    private let stopDataSource: OverviewStopDataSource

    init(stopDataSource: OverviewStopDataSource) {
        self.stopDataSource = stopDataSource
    }

    // MARK: - OverviewFavoriteStopRepository

    func getFavoriteStops() -> AnyPublisher<[OverviewFavoriteStop], Error> {
        return stopDataSource.getFavoriteStops()
    }
}
