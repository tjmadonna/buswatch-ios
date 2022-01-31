//
//  PredictionsStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

struct PredictionsStop {
    let id: String
    let title: String
    let favorite: Bool
}

extension PredictionsStop: Equatable { }

extension PredictionsStop: CustomStringConvertible {

    var description: String {
        return String(format: "id: %@, title: %@", id, title)
    }
}
