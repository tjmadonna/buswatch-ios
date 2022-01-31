//
//  StopMapMKMapKit.swift
//  BusWatch
//
//  Created by Tyler Madonna on 1/30/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {

    var locationBounds: StopMapLocationBounds {
        let northWest = MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY).coordinate
        let southEast = MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY).coordinate
        return StopMapLocationBounds(
            north: northWest.latitude,
            south: southEast.latitude,
            west: northWest.longitude,
            east: southEast.longitude
        )
    }

    func setLocationBounds(_ locationBounds: StopMapLocationBounds, animated: Bool) {
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

    func animateToUserLocation() {
        let location = userLocation.coordinate
        let currentBounds = locationBounds
        let northSouthRange = abs(currentBounds.north - currentBounds.south)
        let westEastRange = abs(currentBounds.west - currentBounds.east)
        let newBounds = StopMapLocationBounds(north: location.latitude + northSouthRange / 2,
                                              south: location.latitude - northSouthRange / 2,
                                              west: location.longitude - westEastRange / 2,
                                              east: location.longitude + westEastRange / 2)
        setLocationBounds(newBounds, animated: true)
    }

    func removeAllAnnotations() {
        removeAnnotations(annotations)
    }
}
