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
    case setLocationBounds(_ locationBounds: StopMapLocationBounds)
    case setLocationBoundsWithStops(_ locationBounds: StopMapLocationBounds, _ stops: [StopMapStop])
    case error(String)
}

// MARK: - Intents

enum StopMapIntent {
    case mapLocationMoved(_ locationBounds: StopMapLocationBounds)
    case stopSelected(_ stop: StopMapStop)
}

// MARK: - Coordinator

protocol StopMapEventCoordinator: AnyObject {

    func stopSelectedInStopMap(_ stopId: String)

}

// MARK: - Resources

protocol StopMapStyle {

    var mapAnnotationTintColor: UIColor { get }

    var locationButtonColor: UIColor { get }

}
