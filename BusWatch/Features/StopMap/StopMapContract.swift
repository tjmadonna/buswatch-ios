//
//  StopMapContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/13/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

// MARK: - States

enum StopMapState {
    case loading
    case setLocationBounds(_ locationBounds: LocationBounds)
    case setLocationBoundsWithStops(_ locationBounds: LocationBounds, _ stops: [DetailedStop])
    case error(String)
}

// MARK: - Intents

enum StopMapIntent {
    case mapLocationMoved(_ locationBounds: LocationBounds)
    case stopSelected(_ stop: DetailedStop)
}

// MARK: - Coordinator

protocol StopMapEventCoordinator: AnyObject {

    func stopSelectedInStopMap(_ stop: DetailedStop)

}
