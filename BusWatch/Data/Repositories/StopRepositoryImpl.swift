//
//  StopRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class StopRepositoryImpl: StopRepository {

    private let database: StopDatabaseDataSource

    init(database: StopDatabaseDataSource) {
        self.database = database
    }

    func getStopById(_ stopId: String) -> AnyPublisher<MinimalStop, Error> {
        return database.getStopById(stopId)
    }

    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        return database.favoriteStop(stopId)
    }

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        return database.unfavoriteStop(stopId)
    }

    func getStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[DetailedStop], Error> {
        return database.getStopsInLocationBounds(locationBounds)
    }

    func getFavoriteStops() -> AnyPublisher<[FavoriteStop], Error> {
        return database.getFavoriteStops()
    }
}
