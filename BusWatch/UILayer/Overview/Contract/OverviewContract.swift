//
//  OverviewContract.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/23/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

// MARK: - Models

struct OverviewSection {
    let title: String
    let items: [OverviewItem]
}

enum OverviewItem {
    case favoriteStop(Stop)
    case emptyFavoriteStop
    case map(LocationBounds)
}

// MARK: - States

enum OverviewState {
    case loading
    case data([OverviewSection])
    case error(String)
}
