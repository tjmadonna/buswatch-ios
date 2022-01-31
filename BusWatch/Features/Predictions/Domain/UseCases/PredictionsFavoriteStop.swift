//
//  PredictionsFavoriteStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/3/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionsFavoriteStop {

    private let stopRepository: PredictionsStopRepository

    init(stopRepository: PredictionsStopRepository) {
        self.stopRepository = stopRepository
    }

    func execute(stopId: String) -> AnyPublisher<Void, Error> {
        return stopRepository.favoriteStop(stopId)
    }
}
