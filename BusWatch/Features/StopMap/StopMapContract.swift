//
//  StopMapContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/13/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit
import UIKit

// MARK: - States

enum StopMapState {
    case loading
    case setCoordinateRegion(_ coordinateRegion: MKCoordinateRegion)
    case setCoordinateRegionWithStopMarkers(_ coordinateRegion: MKCoordinateRegion, _ stopMarkers: [StopMarker])
    case error(String)
}

// MARK: - Intents

enum StopMapIntent {
    case coordinateRegionMoved(_ coordinateRegion: MKCoordinateRegion)
    case stopMarkerSelected(_ stopMarker: StopMarker)
}

// MARK: - Coordinator

protocol StopMapEventCoordinator: AnyObject {

    func stopMarkerSelectedInStopMap(_ stopMarker: StopMarker)

}
