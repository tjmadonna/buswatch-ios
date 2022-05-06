//
//  FilterRoutesComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/20/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

final class FilterRoutesComponent {

    func provideFilterRoutesViewController(_ appComponent: AppComponent,
                                           eventCoordinator: FilterRoutesEventCoordinator,
                                           stopId: String) -> FilterRoutesViewController {

        let viewModel = FilterRoutesViewModel(stopId: stopId,
                                              routeRepository: appComponent.routeRepository,
                                              eventCoordinator: eventCoordinator)

        return FilterRoutesViewController(viewModel: viewModel)
    }
}
