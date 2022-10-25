//
//  FilterRoute.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import DifferenceKit
import Foundation
import GRDB

struct FilterRoute {
    let id: String
    let filtered: Bool
}

//extension FilterRoute: Hashable { }

extension FilterRoute: Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: FilterRoute) -> Bool {
        return id == source.id &&
            filtered == source.filtered
    }

}

extension FilterRoute: CustomStringConvertible {

    var description: String {
        return "id: \(id), filtered: \(filtered)"
    }

}
