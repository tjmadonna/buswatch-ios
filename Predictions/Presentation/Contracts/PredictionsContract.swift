//
//  PredictionsContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Model

//enum PredictionItem: Differentiable {
//
//    typealias DifferenceIdentifier = String?
//
//    case prediction(Prediction)
//    case emptyPrediction
//
//    static func == (lhs: PredictionItem, rhs: PredictionItem) -> Bool {
//        switch (lhs, rhs) {
//        case (let .prediction(lhsPrediction), let .prediction(rhsPrediction)):
//            return lhsPrediction == rhsPrediction
//        case (.emptyPrediction, emptyPrediction):
//            return true
//        default:
//            return false
//        }
//    }
//
//    var differenceIdentifier: String? {
//        switch self {
//        case .prediction(let prediction):
//            return prediction.vehicleId
//        case .emptyPrediction:
//            return nil
//        }
//    }
//
//    func isContentEqual(to source: PredictionItem) -> Bool {
//        return self == source
//    }
//}

// MARK: - States

struct PredictionsNavBarState {
    let favorited: Bool
}

enum PredictionsDataState {
    case loading
    case data([PresentationPrediction])
    case noData
    case error(String)
}

// MARK: - Intent

enum PredictionsIntent {
    case toggleFavorited
}

// MARK: - Coordinator

public protocol PredictionsEventCoordinator : AnyObject {

}

// MARK: - Resources

public protocol PredictionsStyleRepresentable {

    var backgroundColor: UIColor { get }

    var cellBackground: UIColor { get }

    var cellDecoratorColor: UIColor { get }

    var cellDecoratorTextColor: UIColor { get }
}
