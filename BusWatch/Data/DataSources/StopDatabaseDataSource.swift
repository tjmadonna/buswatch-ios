//
//  StopDatabaseDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol StopDatabaseDataSource {

    func getStopById(_ stopId: String) -> AnyPublisher<MinimalStop, Error>

    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error>

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error>

    func getStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[DatabaseDetailedStop], Error>

    func getFavoriteStops() -> AnyPublisher<[DatabaseFavoriteStop], Error>
}
