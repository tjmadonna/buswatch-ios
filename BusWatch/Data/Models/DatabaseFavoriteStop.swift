//
//  DatabaseFavoriteStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/27/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

struct DatabaseFavoriteStop {
    let id: String
    let title: String
    let serviceType: ServiceType
    let routes: [String]
    let excludedRoutes: [String]
}
