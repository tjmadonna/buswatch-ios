//
//  FilterRoutesPresentationRoute.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/19/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import DifferenceKit

struct FilterRoutesPresentationRoute {
    let routeId: String
    let selected: Bool
}

extension FilterRoutesPresentationRoute: Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        routeId
    }

    func isContentEqual(to source: FilterRoutesPresentationRoute) -> Bool {
        return routeId == source.routeId &&
            selected == source.selected
    }
}
