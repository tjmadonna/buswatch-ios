//
//  FavoriteStopRepository.swift
//  Overview
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class FavoriteStopRepository: FavoriteStopRepositoryRepresentable {

    private let favoriteStopDataSource: FavoriteStopDataSourceRepresentable

    public init(favoriteStopDataSource: FavoriteStopDataSourceRepresentable) {
        self.favoriteStopDataSource = favoriteStopDataSource
    }

    // MARK: - FavoriteStopRepositoryRepresentable

    public func getFavoriteStops() -> AnyPublisher<[FavoriteStop], Error> {
        return favoriteStopDataSource.getFavoriteStops()
    }
}
