//
//  PredictionsContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

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

// MARK: - Resources

protocol PredictionsStyle {

    var backgroundColor: UIColor { get }

    var cellBackground: UIColor { get }

    var cellDecoratorColor: UIColor { get }

    var cellDecoratorTextColor: UIColor { get }
}
