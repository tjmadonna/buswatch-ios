//
//  Prediction.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/29/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import DifferenceKit

struct Prediction {
    let id: String
    let title: String
    let route: String
    let capacity: Capacity?
    let arrivalInSeconds: Int
}

extension Prediction: Equatable { }

extension Prediction: Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: Prediction) -> Bool {
        return id == source.id &&
            title == source.title &&
            route == source.route &&
            capacity == source.capacity &&
            arrivalInSeconds == source.arrivalInSeconds
    }

}
