//
//  OverviewGetFavoriteStops.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class OverviewGetFavoriteStops {

    private let favoriteStopRepository: OverviewFavoriteStopRepository

    init(favoriteStopRepository: OverviewFavoriteStopRepository) {
        self.favoriteStopRepository = favoriteStopRepository
    }

    func execute() -> AnyPublisher<[OverviewFavoriteStop], Error> {
        return favoriteStopRepository.getFavoriteStops()
    }
}
