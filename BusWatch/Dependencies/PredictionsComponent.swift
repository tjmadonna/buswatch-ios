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

    func providePredictionsViewController(_ appComponent: AppComponent,
                                          eventCoordinator: PredictionsEventCoordinator,
                                          stop: TitleServiceStop) -> PredictionsViewController {

        let viewModel = PredictionsViewModel(stop: stop,
                                             stopService: appComponent.stopService,
                                             predictionService: appComponent.predictionService,
                                             routeService: appComponent.routeService,
                                             eventCoordinator: eventCoordinator)

        return PredictionsViewController(viewModel: viewModel)
    }
}
