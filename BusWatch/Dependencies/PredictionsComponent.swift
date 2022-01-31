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

        let database = appComponent.provideDatabaseDataSource()
        let urlConfig = UrlConfig(scheme: NetworkConfig.scheme,
                                  host: NetworkConfig.host,
                                  apiKey: NetworkConfig.apiKey,
                                  basePath: NetworkConfig.basePath)
        let urlSource = UrlSourceImpl(urlConfig: urlConfig)

        let stopDataSource = PredictionsStopDataSourceImpl(database: database)
        let stopRepository = PredictionsStopRepositoryImpl(stopDataSource: stopDataSource)

        let predictionDataSource = PredictionsPredictionDataSourceImpl(urlSource: urlSource)
        let routeDataSource = PredictionsRouteDataSourceImpl(database: database)
        let predictionRepository = PredictionsPredictionRepositoryImpl(predictionDataSource: predictionDataSource,
                                                                       routeDataSource: routeDataSource)

        let getStopById = PredictionsGetStopById(stopRepository: stopRepository)
        let getPredictionsForStopId = PredictionsGetPredictionsForStopId(predictionRepository: predictionRepository)
        let favoriteStop = PredictionsFavoriteStop(stopRepository: stopRepository)
        let unfavoriteStop = PredictionsUnfavoriteStop(stopRepository: stopRepository)

        let predictionMapper = PredictionsPresentationPredictionMapper(capacityColor: Colors.capacityImageColor)
        let viewModel = PredictionsViewModel(stopId: stopId,
                                             getStopById: getStopById,
                                             getPredictionsForStopId: getPredictionsForStopId,
                                             favoriteStop: favoriteStop,
                                             unfavoriteStop: unfavoriteStop,
                                             eventCoordinator: eventCoordinator,
                                             predictionMapper: predictionMapper)
        let style = PredictionsStyleImpl()

        return PredictionsViewController(viewModel: viewModel, style: style)
    }
}
