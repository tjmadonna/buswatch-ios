//
//  StopMapComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/7/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit
import StopMap

final class StopMapComponent {

    private struct StopMapStyle : StopMapStyleRepresentable {

        let mapAnnotationTintColor = Colors.navBarColor

        var locationButtonColor = Colors.darkRaisedBackgroundColor
    }

    func provideStopMapViewController(_ appComponent: AppComponent,
                                      eventCoordinator: StopMapEventCoordinator) -> StopMapViewController {

        let database = appComponent.provideDatabaseDataSource()
        let locationManager = CLLocationManager()

        let stopDataSource = StopDataSource(database: database)
        let stopRepository = StopRepository(stopDataSource: stopDataSource)

        let locationDataSource = LocationDataSource(database: database)
        let locationPermissionDataSource = LocationPermissionDataSource(locationManager: locationManager)
        let locationRepository = LocationRepository(locationDataSource: locationDataSource,
                                                    locationPermissionDataSource: locationPermissionDataSource)

        let getStopsInLocationBounds = GetStopsInLocationBounds(stopRepository: stopRepository)
        let getLastLocationBounds = GetLastLocationBounds(locationRepository: locationRepository)
        let saveLastLocationBounds = SaveLastLocationBounds(locationRepository: locationRepository)
        let getCurrentLocationPermissionStatus = GetCurrentLocationPermissionStatus(locationRepository: locationRepository)

        let viewModel = StopMapViewModel(getStopsInLocationBounds: getStopsInLocationBounds,
                                          getLastLocationBounds: getLastLocationBounds,
                                          saveLastLocationBounds: saveLastLocationBounds,
                                          getCurrentLocationPermissionStatus: getCurrentLocationPermissionStatus,
                                          eventCoordinator: eventCoordinator)
        let style = StopMapStyle()

        return StopMapViewController(viewModel: viewModel, style: style)
    }
}
