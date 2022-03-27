//
//  FavoriteStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

struct FavoriteStop {
    let id: String
    let title: String
    let routes: [String]
}

extension FavoriteStop: Hashable { }

extension FavoriteStop: CustomStringConvertible {

    var description: String {
        return String(format: "id: %@, title: %@", id, title)
    }
}
