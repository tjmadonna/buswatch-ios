//
//  DetailedStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

struct DetailedStop {
    let id: String
    let title: String
    let serviceType: ServiceType
    let latitude: Double
    let longitude: Double
    let filteredRoutes: [String]
}

extension DetailedStop: Hashable { }

extension DetailedStop: CustomStringConvertible {

    var description: String {
        return String(format: "id: %@, latitude: %.4f, longitude: %.4f", id, latitude, longitude)
    }
}
