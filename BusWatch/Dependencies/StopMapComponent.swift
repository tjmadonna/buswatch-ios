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

    private struct StopMapStyleImpl: StopMapStyle {

        let mapAnnotationTintColor = Colors.navBarColor

        var locationButtonColor = Colors.darkRaisedBackgroundColor
    }

    func provideStopMapViewController(_ appComponent: AppComponent,
                                      eventCoordinator: StopMapEventCoordinator) -> StopMapViewController {

        let viewModel = StopMapViewModel(stopRepository: appComponent.stopRepository,
                                         locationRepository: appComponent.locationRepository,
                                         eventCoordinator: eventCoordinator)
        let style = StopMapStyleImpl()

        return StopMapViewController(viewModel: viewModel, style: style)
    }
}
