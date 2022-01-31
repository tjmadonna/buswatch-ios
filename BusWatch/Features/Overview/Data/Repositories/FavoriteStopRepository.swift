//
//  OverviewFavoriteStopRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class OverviewFavoriteStopRepositoryImpl: OverviewFavoriteStopRepository {

    private let favoriteStopDataSource: OverviewFavoriteStopDataSource

    init(favoriteStopDataSource: OverviewFavoriteStopDataSource) {
        self.favoriteStopDataSource = favoriteStopDataSource
    }

    // MARK: - OverviewFavoriteStopRepository

    func getFavoriteStops() -> AnyPublisher<[OverviewFavoriteStop], Error> {
        return favoriteStopDataSource.getFavoriteStops()
    }
}
