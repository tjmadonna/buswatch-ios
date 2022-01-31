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

        let locationDataSource = StopMapLocationDataSourceImpl(database: database)
        let locationPermissionDataSource = StopMapLocationPermissionDataSourceImpl(locationManager: locationManager)
        let locationRepository = StopMapLocationRepositoryImpl(locationDataSource: locationDataSource,
                                                        locationPermissionDataSource: locationPermissionDataSource)

        let getStopsInLocationBounds = StopMapGetStopsInLocationBounds(stopRepository: stopRepository)
        let getLastLocationBounds = StopMapGetLastLocationBounds(locationRepository: locationRepository)
        let saveLastLocationBounds = StopMapSaveLastLocationBounds(locationRepository: locationRepository)
        let getPermissionStatus = StopMapGetCurrentLocationPermissionStatus(locationRepository: locationRepository)

        let viewModel = StopMapViewModel(getStopsInLocationBounds: getStopsInLocationBounds,
                                          getLastLocationBounds: getLastLocationBounds,
                                          saveLastLocationBounds: saveLastLocationBounds,
                                          getCurrentLocationPermissionStatus: getPermissionStatus,
                                          eventCoordinator: eventCoordinator)
        let style = StopMapStyleImpl()

        return StopMapViewController(viewModel: viewModel, style: style)
    }
}
