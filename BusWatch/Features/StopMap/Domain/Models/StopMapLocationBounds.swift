//
//  StopMapLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 1/30/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

struct StopMapLocationBounds {
    let north: Double
    let south: Double
    let west: Double
    let east: Double
}

extension StopMapLocationBounds: Equatable { }

extension StopMapLocationBounds: CustomStringConvertible {

    var description: String {
        return "north: \(north), south: \(south), west: \(west), east: \(east)"
    }
}
