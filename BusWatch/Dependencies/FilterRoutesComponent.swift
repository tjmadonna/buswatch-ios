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

        let service = FilterRoutesService(database: appComponent.database,
                                          eventCoordinator: eventCoordinator)

        let viewModel = FilterRoutesViewModel(stopId: stopId,
                                              service: service,
                                              eventCoordinator: eventCoordinator)

        return FilterRoutesViewController(viewModel: viewModel)
    }

}
