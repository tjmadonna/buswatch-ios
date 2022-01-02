//
//  FilterRoutesContract.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

// MARK: - States

enum FilterRoutesState {
    case loading
    case data([PresentationRoute])
    case error(String)
}

// MARK: - Intent

enum FilterRoutesIntent {
    case routeSelected(Int)
    case saveSelected
    case cancelSelected
}

// MARK: - Coordinator

public protocol FilterRoutesEventCoordinator : AnyObject {

    func saveSelectedInFilterRoutes()

    func cancelSelectedInFilterRoutes()
}
