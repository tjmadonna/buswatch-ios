//
//  StopMapContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/13/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

// MARK: - States

enum StopMapState {
    case loading
    case setLocationBounds(_ locationBounds: LocationBounds)
    case setLocationBoundsWithStops(_ locationBounds: LocationBounds, _ stops: [Stop])
    case error(String)
}

// MARK: - Intents

enum StopMapIntent {
    case moveMapLocationBounds(_ locationBounds: LocationBounds)
    case showPredictionsForStop(_ stop: Stop)
}
