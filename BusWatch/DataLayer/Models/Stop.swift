//
//  Stop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import DifferenceKit

struct Stop {
    let id: String
    let title: String
    let favorite: Bool
    let latitude: Double
    let longitude: Double
    let routes: [String]
}

extension Stop: Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String { id }

    func isContentEqual(to source: Stop) -> Bool {
        return self.id == source.id &&
            self.title == source.title &&
            self.favorite == source.favorite &&
            self.latitude == source.latitude &&
            self.longitude == source.longitude &&
            self.routes == source.routes
    }
}

extension Stop: CustomStringConvertible {

    var description: String {
        return String(format: "id: %@, latitude: %.4f, longitude: %.4f", id, latitude, longitude)
    }
}
