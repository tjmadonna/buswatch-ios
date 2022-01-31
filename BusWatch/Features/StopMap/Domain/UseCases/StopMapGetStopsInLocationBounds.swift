//
//  StopMapGetStopsInLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class StopMapGetStopsInLocationBounds {

    private let stopRepository: StopMapStopRepository

    init(stopRepository: StopMapStopRepository) {
        self.stopRepository = stopRepository
    }

    func execute(locationBounds: StopMapLocationBounds) -> AnyPublisher<[StopMapStop], Error> {
        return stopRepository.getStopsInLocationBounds(locationBounds)
    }
}
