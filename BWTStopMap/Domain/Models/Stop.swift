//
//  Stop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

public struct Stop {
    let id: String
    let title: String
    let latitude: Double
    let longitude: Double
    let routes: [String]
}

extension Stop: Equatable { }

extension Stop: CustomStringConvertible {

    public var description: String {
        return String(format: "id: %@, latitude: %.4f, longitude: %.4f", id, latitude, longitude)
    }
}
