//
//  PredictionsStopRepositoryImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionsStopRepositoryImpl: PredictionsStopRepository {

    private let stopDataSource: PredictionsStopDataSource

    init(stopDataSource: PredictionsStopDataSource) {
        self.stopDataSource = stopDataSource
    }

    // MARK: - PredictionsStopRepository

    func getStopById(_ stopId: String) -> AnyPublisher<PredictionsStop, Error> {
        return stopDataSource.getStopById(stopId)
    }

    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        return stopDataSource.favoriteStop(stopId)
    }

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        return stopDataSource.unfavoriteStop(stopId)
    }
}
