//
//  OverviewComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/6/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Overview

final class OverviewComponent {

    private struct OverviewStyle : OverviewStyleRepresentable {

        let backgroundColor = Colors.backgroundColor

        let cellBackground = Colors.raisedBackgroundColor

        let cellDecoratorColor = Colors.decoratorBackgroundColor

        let cellDecoratorTextColor = Colors.decoratorTextBackgroundColor
    }

    func provideOverviewViewController(_ appComponent: AppComponent,
                                       eventCoordinator: OverviewEventCoordinator) -> OverviewViewController {

        let database = appComponent.provideDatabaseDataSource()

        let favoriteStopDataSource = FavoriteStopDataSource(database: database)
        let favoriteStopRepository = FavoriteStopRepository(favoriteStopDataSource: favoriteStopDataSource)

        let locationDataSource = LocationDataSource(database: database)
        let locationRepository = LocationRepository(locationDataSource: locationDataSource)

        let getFavoriteStops = GetFavoriteStops(favoriteStopRepository: favoriteStopRepository)
        let getLastLocationBounds = GetLastLocationBounds(locationRepository: locationRepository)

        let viewModel = OverviewViewModel(getFavoriteStops: getFavoriteStops,
                                          getLastLocationBounds: getLastLocationBounds,
                                          eventCoordinator: eventCoordinator)
        let style = OverviewStyle()

        return OverviewViewController(viewModel: viewModel, style: style)
    }
}
