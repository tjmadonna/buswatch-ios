//
//  StopMapComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/7/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit

final class StopMapComponent {

    func provideStopMapViewController(_ appComponent: AppComponent,
                                      eventCoordinator: StopMapEventCoordinator) -> StopMapViewController {

        let viewModel = StopMapViewModel(stopService: appComponent.stopService,
                                         locationService: appComponent.locationService,
                                         eventCoordinator: eventCoordinator)

        return StopMapViewController(viewModel: viewModel)
    }
}
