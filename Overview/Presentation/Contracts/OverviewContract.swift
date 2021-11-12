//
//  OverviewContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/23/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Models

struct OverviewSection {
    let title: String
    let items: [OverviewItem]
}

enum OverviewItem {
    case favoriteStop(FavoriteStop)
    case emptyFavoriteStop
    case map(LocationBounds)
}

// MARK: - States

enum OverviewState {
    case loading
    case data([OverviewSection])
    case error(String)
}

// MARK: - Intent

enum OverviewIntent {
    case favoriteStopSelected(_ favoriteStop: FavoriteStop)
    case stopMapSelected
}

// MARK: - Coordinator

public protocol OverviewEventCoordinator : AnyObject {

    func favoriteStopSelectedInOverview(_ stopId: String)

    func stopMapSelectedInOverview()

}

// MARK: - Resources

public protocol OverviewStyleRepresentable {

    var backgroundColor: UIColor { get }

    var cellBackground: UIColor { get }

    var cellDecoratorColor: UIColor { get }

    var cellDecoratorTextColor: UIColor { get }

}
