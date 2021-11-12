//
//  MKMapView.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import MapKit

extension MKMapView {

    var nullPoint: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    var locationBounds: LocationBounds {
        let northWest = MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY).coordinate
        let southEast = MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY).coordinate
        return LocationBounds(
            north: northWest.latitude,
            south: southEast.latitude,
            west: northWest.longitude,
            east: southEast.longitude
        )
    }

    func setLocationBounds(_ locationBounds: LocationBounds, animated: Bool) {
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
        let newBounds = LocationBounds(north: location.latitude + northSouthRange / 2,
                                       south: location.latitude - northSouthRange / 2,
                                       west: location.longitude - westEastRange / 2,
                                       east: location.longitude + westEastRange / 2)
        setLocationBounds(newBounds, animated: true)
    }

    func removeAllAnnotations() {
        removeAnnotations(annotations)
    }
}
