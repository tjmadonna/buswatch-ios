//
//  MKMapView+Utils.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {

    func animateToUserLocation() {
        let userLocation = MKCoordinateRegion(center: userLocation.coordinate, span: region.span)
        setRegion(userLocation, animated: true)
    }

    func removeAllAnnotations() {
        removeAnnotations(annotations)
    }

}
