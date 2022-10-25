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

        let service = StopMapService(database: appComponent.database,
                                     userDefaults: appComponent.userDefaults)

        let viewModel = StopMapViewModel(service: service, eventCoordinator: eventCoordinator)

        return StopMapViewController(viewModel: viewModel)
    }
    
}
