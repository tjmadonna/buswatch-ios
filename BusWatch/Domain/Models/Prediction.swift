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
    let capacityImageName: String?
    let arrivalMessage: String
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
            capacityImageName == source.capacityImageName &&
            arrivalMessage == source.arrivalMessage
    }
}
