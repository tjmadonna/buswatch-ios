//
//  PresentationPrediction.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/3/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

struct PresentationPrediction {
    let vehicleId: String
    let title: String
    let route: String
    let capacity: UIImage?
    let capacityColor: UIColor?
    let arrivalMessage: String
    let color: UIColor?
}

extension PresentationPrediction : Differentiable {

    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        vehicleId
    }

    func isContentEqual(to source: PresentationPrediction) -> Bool {
        return vehicleId == source.vehicleId &&
            title == source.title &&
            capacity == source.capacity &&
            arrivalMessage == source.arrivalMessage &&
            color == source.color
    }
}
