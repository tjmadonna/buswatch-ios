//
//  DefaultCoordinateRegion.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import MapKit

let defaultCoordinateRegion: MKCoordinateRegion = {
    let center = CLLocationCoordinate2D(latitude: 40.437718693889764, longitude: -79.99561212860195)
    let span = MKCoordinateSpan(latitudeDelta: 0.047, longitudeDelta: 0.034)
    return MKCoordinateRegion(center: center, span: span)
}()
