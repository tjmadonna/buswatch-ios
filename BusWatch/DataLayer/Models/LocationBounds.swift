//
//  LocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
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
