//
//  PredictionsPresentationPrediction.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/3/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

struct PredictionsPresentationPrediction {
    let vehicleId: String
    let title: String
    let route: String
    let capacity: UIImage?
    let capacityColor: UIColor?
    let arrivalMessage: String
    let color: UIColor?
}

extension PredictionsPresentationPrediction: Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        vehicleId
    }

    func isContentEqual(to source: PredictionsPresentationPrediction) -> Bool {
        return vehicleId == source.vehicleId &&
            title == source.title &&
            capacity == source.capacity &&
            arrivalMessage == source.arrivalMessage &&
            color == source.color
    }
}
