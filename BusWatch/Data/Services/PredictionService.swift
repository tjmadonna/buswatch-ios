//
//  PredictionService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation

protocol PredictionService {

    func observePredictionsForStopId(_ stopId: String, serviceType: ServiceType, updateInterval: TimeInterval)
        -> AnyPublisher<LoadingResponse<[Prediction]>, Error>

}

final class PredictionServiceImpl: PredictionService {

    static private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyyMMdd HH:mm"
        return dateFormatter
    }()

    private let networkDataSource: NetworkDataSource

    private let routeDataSource: RouteDbDataSource

    init(networkDataSource: NetworkDataSource, routeDataSource: RouteDbDataSource) {
        self.networkDataSource = networkDataSource
        self.routeDataSource = routeDataSource
    }

    func observePredictionsForStopId(_ stopId: String, serviceType: ServiceType, updateInterval: TimeInterval = 15)
        -> AnyPublisher<LoadingResponse<[Prediction]>, Error> {

        return networkDataSource.observePredictionsForStopId(stopId,
                                                             serviceType: serviceType,
                                                             updateInterval: updateInterval)
        .map { [unowned self] response in
            self.mapNetworkResponse(response)
        }
        .eraseToAnyPublisher()
    }

    private func mapNetworkResponse(_ response: LoadingResponse<[NetworkPrediction]>) -> LoadingResponse<[Prediction]> {
        switch response {
        case .loading:
            return .loading
        case .success(let networkPredictions):
            let routeIds = networkPredictions.compactMap { prediction in prediction.routeId }
            let dbRoutesResult = routeDataSource.getRoutesWithIds(routeIds)
            switch dbRoutesResult {
            case .success(let dbRoutes):
                let routeMap = Dictionary(uniqueKeysWithValues: dbRoutes.map { route in (route.id, route) })
                let routes = networkPredictions.compactMap { prediction in
                    prediction.toPrediction(route: routeMap[prediction.routeId ?? ""],
                                            dateFormatter: PredictionServiceImpl.dateFormatter)
                }
                return .success(routes)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
