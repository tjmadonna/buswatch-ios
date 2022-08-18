//
//  OverviewComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/6/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

final class OverviewComponent {

    func provideOverviewViewController(_ appComponent: AppComponent,
                                       eventCoordinator: OverviewEventCoordinator) -> OverviewViewController {

        let viewModel = OverviewViewModel(stopService: appComponent.stopService,
                                          locationService: appComponent.locationService,
                                          eventCoordinator: eventCoordinator)

        return OverviewViewController(viewModel: viewModel)
    }
}
