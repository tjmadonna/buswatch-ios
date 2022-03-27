//
//  PredictionsComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/7/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

final class PredictionsComponent {

    private struct PredictionsStyleImpl: PredictionsStyle {

        let backgroundColor = Colors.backgroundColor

        let cellBackground = Colors.raisedBackgroundColor

        let cellDecoratorColor = Colors.decoratorBackgroundColor

        let cellDecoratorTextColor = Colors.decoratorTextBackgroundColor

    }

    func providePredictionsViewController(_ appComponent: AppComponent,
                                          eventCoordinator: PredictionsEventCoordinator,
                                          stopId: String) -> PredictionsViewController {

        let viewModel = PredictionsViewModel(stopId: stopId,
                                             stopRepository: appComponent.stopRepository,
                                             predictionRepository: appComponent.predictionRepository,
                                             eventCoordinator: eventCoordinator)
        let style = PredictionsStyleImpl()

        return PredictionsViewController(viewModel: viewModel, style: style)
    }
}
