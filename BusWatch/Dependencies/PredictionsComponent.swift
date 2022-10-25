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
                                          stop: PredictionsStop) -> PredictionsViewController {

        let service = PredictionsService(database: appComponent.database,
                                         urlSession: appComponent.urlSession,
                                         urlSource: appComponent.urlSource)
        
        let viewModel = PredictionsViewModel(stop: stop,
                                             service: service,
                                             eventCoordinator: eventCoordinator)

        return PredictionsViewController(viewModel: viewModel)
    }

}
