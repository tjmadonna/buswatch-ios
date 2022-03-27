//
//  ExclusionRoute.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import DifferenceKit

struct ExclusionRoute {
    let id: String
    let excluded: Bool
}

extension ExclusionRoute: Hashable { }

extension ExclusionRoute: Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: ExclusionRoute) -> Bool {
        return id == source.id &&
            excluded == source.excluded
    }
}

extension ExclusionRoute: CustomStringConvertible {

    var description: String {
        return "id: \(id), excluded: \(excluded)"
    }
}
