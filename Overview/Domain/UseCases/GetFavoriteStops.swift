//
//  GetFavoriteStops.swift
//  Overview
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class GetFavoriteStops {

    private let favoriteStopRepository: FavoriteStopRepositoryRepresentable

    public init(favoriteStopRepository: FavoriteStopRepositoryRepresentable) {
        self.favoriteStopRepository = favoriteStopRepository
    }

    func execute() -> AnyPublisher<[FavoriteStop], Error> {
        return favoriteStopRepository.getFavoriteStops()
    }
}
