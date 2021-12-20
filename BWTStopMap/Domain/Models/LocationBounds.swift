//
//  LocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

public struct LocationBounds {
    let north: Double
    let south: Double
    let west: Double
    let east: Double
}

extension LocationBounds: Equatable { }

extension LocationBounds: CustomStringConvertible {

    public var description: String {
        return "north: \(north), south: \(south), west: \(west), east: \(east)"
    }
}
