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
                                          stopId: String,
                                          serviceType: ServiceType) -> PredictionsViewController {

        let viewModel = PredictionsViewModel(stopId: stopId,
                                             serviceType: serviceType,
                                             stopRepository: appComponent.stopRepository,
                                             predictionRepository: appComponent.predictionRepository,
                                             eventCoordinator: eventCoordinator)

        return PredictionsViewController(viewModel: viewModel)
    }
}
