//
//  DatabaseStop.swift
//  Database
//
//  Created by Tyler Madonna on 11/4/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import DifferenceKit

struct DatabaseStop {

    let id: String

    let title: String

    let latitude: Double

    let longitude: Double

    let routes: [String]
}

extension DatabaseStop: Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: DatabaseStop) -> Bool {
        return id == source.id &&
            title == source.title &&
            latitude == source.latitude &&
            longitude == source.longitude &&
            routes == source.routes
    }
}
