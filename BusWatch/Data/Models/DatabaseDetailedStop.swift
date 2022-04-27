//
//  DatabaseDetailedStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/27/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

struct DatabaseDetailedStop {
    let id: String
    let title: String
    let serviceType: ServiceType
    let latitude: Double
    let longitude: Double
    let routes: [String]
    let excludedRoutes: [String]
}
