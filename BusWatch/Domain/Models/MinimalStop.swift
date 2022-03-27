//
//  MinimalStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

struct MinimalStop {
    let id: String
    let title: String
    let favorite: Bool
}

extension MinimalStop: Hashable { }

extension MinimalStop: CustomStringConvertible {

    var description: String {
        return String(format: "id: %@, title: %@", id, title)
    }
}
