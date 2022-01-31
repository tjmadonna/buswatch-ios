//
//  OverviewFavoriteStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

struct OverviewFavoriteStop {
    let id: String
    let title: String
    let routes: [String]
}

extension OverviewFavoriteStop: Equatable { }

extension OverviewFavoriteStop: CustomStringConvertible {

    var description: String {
        return String(format: "id: %@, title: %@", id, title)
    }
}
