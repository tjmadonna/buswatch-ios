//
//  MKMapKit.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/30/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {

    func setLocationBounds(_ locationBounds: OverviewLocationBounds, animated: Bool) {
        let northWestCoor = CLLocationCoordinate2DMake(locationBounds.north, locationBounds.west)
        let southEastCoor = CLLocationCoordinate2DMake(locationBounds.south, locationBounds.east)

        let northWestPoint = MKMapPoint(northWestCoor)
        let southEastPoint = MKMapPoint(southEastCoor)

        let mapRect = MKMapRect(
            x: min(northWestPoint.x, southEastPoint.x),
            y: min(northWestPoint.y, southEastPoint.y),
            width: abs(northWestPoint.x - southEastPoint.x),
            height: abs(northWestPoint.y - southEastPoint.y)
        )
        setVisibleMapRect(mapRect, animated: animated)
    }
}
