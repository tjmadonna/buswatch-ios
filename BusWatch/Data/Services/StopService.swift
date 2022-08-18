//
//  StopService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation

protocol StopService {

    func observeStopById(_ stopId: String) -> AnyPublisher<MinimalStop, Error>
    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error>
    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error>
    func observeStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[DetailedStop], Error>
    func observeFavoriteStops() -> AnyPublisher<[FavoriteStop], Error>

}

final class StopServiceImpl: StopService {

    private let dbDataSource: StopDbDataSource

    init(dbDataSource: StopDbDataSource) {
        self.dbDataSource = dbDataSource
    }

    func observeStopById(_ stopId: String) -> AnyPublisher<MinimalStop, Error> {
        return dbDataSource.observeStopById(stopId)
            .map { dbStop in dbStop.toMinimalStop() }
            .eraseToAnyPublisher()
    }

    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        return dbDataSource.insertFavoriteStop(stopId)
    }

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        return dbDataSource.deleteFavoriteStop(stopId)
    }

    func observeStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[DetailedStop], Error> {
        return dbDataSource.observeStopsInLocationBounds(locationBounds)
            .map { dbStops in dbStops.map { dbStop in dbStop.toDetailedStop() } }
            .eraseToAnyPublisher()
    }

    func observeFavoriteStops() -> AnyPublisher<[FavoriteStop], Error> {
        return dbDataSource.observeFavoriteStops()
            .map { dbStops in dbStops.map { dbStop in dbStop.toFavoriteStop() } }
            .eraseToAnyPublisher()
    }

}
