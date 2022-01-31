//
//  StopMapStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

struct StopMapStop {
    let id: String
    let title: String
    let latitude: Double
    let longitude: Double
    let routes: [String]
}

extension StopMapStop: Equatable { }

extension StopMapStop: CustomStringConvertible {

    var description: String {
        return String(format: "id: %@, latitude: %.4f, longitude: %.4f", id, latitude, longitude)
    }
}
