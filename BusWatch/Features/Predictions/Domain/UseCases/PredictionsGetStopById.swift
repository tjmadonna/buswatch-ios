//
//  PredictionsGetStopById.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionsGetStopById {

    private let stopRepository: PredictionsStopRepository

    init(stopRepository: PredictionsStopRepository) {
        self.stopRepository = stopRepository
    }

    func execute(stopId: String) -> AnyPublisher<PredictionsStop, Error> {
        return stopRepository.getStopById(stopId)
    }
}
