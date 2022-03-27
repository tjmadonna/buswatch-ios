//
//  OverviewComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/6/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

final class OverviewComponent {

    private struct OverviewStyleImpl: OverviewStyle {

        let backgroundColor = Colors.backgroundColor

        let cellBackground = Colors.raisedBackgroundColor

        let cellDecoratorColor = Colors.decoratorBackgroundColor

        let cellDecoratorTextColor = Colors.decoratorTextBackgroundColor
    }

    func provideOverviewViewController(_ appComponent: AppComponent,
                                       eventCoordinator: OverviewEventCoordinator) -> OverviewViewController {

        let viewModel = OverviewViewModel(stopRepository: appComponent.stopRepository,
                                          locationRepository: appComponent.locationRepository,
                                          eventCoordinator: eventCoordinator)
        let style = OverviewStyleImpl()

        return OverviewViewController(viewModel: viewModel, style: style)
    }
}
