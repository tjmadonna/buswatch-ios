//
//  DefaultCoordinateRegion.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import MapKit

let defaultCoordinateRegion: MKCoordinateRegion = {
    let center = CLLocationCoordinate2D(latitude: 40.43761400152732, longitude: -79.99694668348725)
    let span = MKCoordinateSpan(latitudeDelta: 0.018638820689957925, longitudeDelta: 0.01328327616849378)
    return MKCoordinateRegion(center: center, span: span)
}()
