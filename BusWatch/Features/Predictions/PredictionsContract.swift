//
//  PredictionsContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import DifferenceKit
import Foundation
import UIKit

protocol PredictionsDataItemConformable: Differentiable where DifferenceIdentifier == String {
}

struct PredictionsMessageDataItem : PredictionsDataItemConformable {
    let message: String

    var differenceIdentifier: String {
        return message
    }
    
    func isContentEqual(to source: PredictionsMessageDataItem) -> Bool {
        return message == source.message
    }
}

struct PredictionsPredictionDataItem: PredictionsDataItemConformable {
    let id: String
    let title: String
    let route: String
    let capacity: Capacity?
    let arrivalInSeconds: Int

    init(prediction: Prediction) {
        self.id = prediction.id
        self.title = prediction.title
        self.route = prediction.route
        self.capacity = prediction.capacity
        self.arrivalInSeconds = prediction.arrivalInSeconds
    }

    var differenceIdentifier: String {
        return id
    }

    func isContentEqual(to source: PredictionsPredictionDataItem) -> Bool {
        return id == source.id &&
            title == source.title &&
            route == source.route &&
            capacity == source.capacity &&
            arrivalInSeconds == source.arrivalInSeconds
    }
}






// MARK: - States

struct PredictionsNavBarState {
    let favorited: Bool
    let title: String
}

enum PredictionsDataState {
    case loading
    case data([Prediction])
    case noData
    case error(String)
}

// MARK: - Intent

enum PredictionsIntent {
    case toggleFavorited
    case filterRoutesSelected
}

// MARK: - Coordinator

protocol PredictionsEventCoordinator: AnyObject {
    func filterRoutesSelectedInFilterRoutes(_ stopId: String)
}
