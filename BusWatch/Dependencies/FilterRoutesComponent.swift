//
//  FilterRoutesComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/20/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit
import FilterRoutes

final class FilterRoutesComponent {

    func provideFilterRoutesViewController(_ appComponent: AppComponent,
                                           eventCoordinator: FilterRoutesEventCoordinator,
                                           stopId: String) -> FilterRoutesViewController {

        let database = appComponent.provideDatabaseDataSource()

        let dataSource = RouteDataSource(database: database)
        let repository = RouteRepository(routeDataSource: dataSource)

        let getRoutesForStopId = GetRoutesForStopId(routeRepository: repository)
        let updateExcludedRoutes = UpdateExcludedRoutes(routeRepository: repository)

        let viewModel = FilterRoutesViewModel(stopId: stopId,
                                              getRoutesForStopId: getRoutesForStopId,
                                              updateExcludedRoutes: updateExcludedRoutes,
                                              eventCoordinator: eventCoordinator)

        return FilterRoutesViewController(viewModel: viewModel)
    }
}
