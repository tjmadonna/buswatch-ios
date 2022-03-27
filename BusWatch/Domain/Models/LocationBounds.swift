//
//  LocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

struct LocationBounds {
    let north: Double
    let south: Double
    let west: Double
    let east: Double
}

extension LocationBounds: Hashable { }

extension LocationBounds: CustomStringConvertible {

    var description: String {
        return "north: \(north), south: \(south), west: \(west), east: \(east)"
    }
}
