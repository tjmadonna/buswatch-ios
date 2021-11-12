//
//  LocationBounds.swift
//  Overview
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
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
