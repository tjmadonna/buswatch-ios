//
//  FilterableRoute.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import DifferenceKit

struct FilterableRoute {
    let id: String
    let filtered: Bool
}

extension FilterableRoute: Hashable { }

extension FilterableRoute: Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: FilterableRoute) -> Bool {
        return id == source.id &&
            filtered == source.filtered
    }
}

extension FilterableRoute: CustomStringConvertible {

    var description: String {
        return "id: \(id), excluded: \(filtered)"
    }
}
