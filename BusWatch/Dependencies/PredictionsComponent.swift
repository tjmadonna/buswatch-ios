//
//  PredictionsComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/7/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Predictions
import Network
import UIKit

final class PredictionsComponent {

    private struct PredictionsStyle : PredictionsStyleRepresentable {
        
        let backgroundColor = Colors.backgroundColor

        let cellBackground = Colors.raisedBackgroundColor

        let cellDecoratorColor = Colors.decoratorBackgroundColor

        let cellDecoratorTextColor = Colors.decoratorTextBackgroundColor

    }

    func providePredictionsViewController(_ appComponent: AppComponent,
                                          eventCoordinator: PredictionsEventCoordinator,
                                          stopId: String) -> PredictionsViewController {

        let database = appComponent.provideDatabaseDataSource()
        let urlConfig = UrlConfig(scheme: NetworkConfig.scheme,
                                  host: NetworkConfig.host,
                                  apiKey: NetworkConfig.apiKey,
                                  basePath: NetworkConfig.basePath)
        let urlSource = UrlSource(urlConfig: urlConfig)

        let stopDataSource = StopDataSource(database: database)
        let stopRepository = StopRepository(stopDataSource: stopDataSource)

        let predictionDataSource = PredictionDataSource(urlSource: urlSource)
        let routeDataSource = RouteDataSource(database: database)
        let predictionRepository = PredictionRepository(predictionDataSource: predictionDataSource,
                                                        routeDataSource: routeDataSource)

        let getStopById = GetStopById(stopRepository: stopRepository)
        let getPredictionsForStopId = GetPredictionsForStopId(predictionRepository: predictionRepository)
        let favoriteStop = FavoriteStop(stopRepository: stopRepository)
        let unfavoriteStop = UnfavoriteStop(stopRepository: stopRepository)

        let predictionMapper = PresentationPredictionMapper(capacityColor: Colors.capacityImageColor)
        let viewModel = PredictionsViewModel(stopId: stopId,
                                             getStopById: getStopById,
                                             getPredictionsForStopId: getPredictionsForStopId,
                                             favoriteStop: favoriteStop,
                                             unfavoriteStop: unfavoriteStop,
                                             eventCoordinator: eventCoordinator,
                                             predictionMapper: predictionMapper)
        let style = PredictionsStyle()

        return PredictionsViewController(viewModel: viewModel, style: style)
    }
}
