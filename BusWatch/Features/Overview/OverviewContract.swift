//
//  OverviewContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/23/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit
import UIKit

// MARK: - Models

struct OverviewSection {
    let title: String
    let items: [OverviewItem]
}

enum OverviewItem {
    case favoriteStop(OverviewFavoriteStop)
    case emptyFavoriteStop
    case map(MKCoordinateRegion)
}

// MARK: - States

enum OverviewState {
    case loading
    case data([OverviewSection])
    case error(String)
}

// MARK: - Intent

enum OverviewIntent {
    case favoriteStopSelected(_ favoriteStop: OverviewFavoriteStop)
    case stopMapSelected
}

// MARK: - Coordinator

protocol OverviewEventCoordinator: AnyObject {

    func favoriteStopSelectedInOverview(_ stop: OverviewFavoriteStop)

    func stopMapSelectedInOverview()

}
