//
//  StopRepository.swift
//  Predictions
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class StopRepository : StopRepositoryRepresentable {

    private let stopDataSource: StopDataSourceRepresentable

    public init(stopDataSource: StopDataSourceRepresentable) {
        self.stopDataSource = stopDataSource
    }

    public func getStopById(_ stopId: String) -> AnyPublisher<Stop, Error> {
        return stopDataSource.getStopById(stopId)
    }

    public func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        return stopDataSource.favoriteStop(stopId)
    }

    public func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        return stopDataSource.unfavoriteStop(stopId)
    }
}
