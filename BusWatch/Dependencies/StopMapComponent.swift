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

        let database = appComponent.provideDatabaseDataSource()
        let locationManager = CLLocationManager()

        let stopDataSource = StopMapStopDataSourceImpl(database: database)
        let stopRepository = StopMapStopRepositoryImpl(stopDataSource: stopDataSource)

        let locDataSource = StopMapLocationDataSourceImpl(database: database)
        let locPermissionDataSource = StopMapLocationPermissionDataSourceImpl(locationManager: locationManager)
        let locRepository = StopMapLocationRepositoryImpl(locationDataSource: locDataSource,
                                                          locationPermissionDataSource: locPermissionDataSource)

        let viewModel = StopMapViewModel(stopRepository: stopRepository,
                                         locationRepository: locRepository,
                                         eventCoordinator: eventCoordinator)
        let style = StopMapStyleImpl()

        return StopMapViewController(viewModel: viewModel, style: style)
    }
}
