//
//  PredictionsPredictionDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionsPredictionDataSourceImpl: PredictionsPredictionDataSource {

    private let urlSource: UrlSource

    private let urlSession: URLSession

    private let mapper: PredictionsDataPredictionMapper

    init(urlSource: UrlSource,
         urlSession: URLSession = URLSession.shared,
         mapper: PredictionsDataPredictionMapper = PredictionsDataPredictionMapper()) {
        self.urlSource = urlSource
        self.urlSession = urlSession
        self.mapper = mapper
    }

    // MARK: - PredictionsPredictionDataSource

    func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[PredictionsDataPrediction], Error> {

        let url = urlSource.authenticatedPredictionsURLForStopId(stopId)

        return TimedNetworkPublisher<PredictionsNetworkGetPredictionsResponse>(url: url,
                                                                               timeInterval: 30,
                                                                               urlSession: self.urlSession)
            .map { response in response.bustimeResponse?.predictions ?? [] }
            .map { [weak self] predictions in
                self?.mapper.mapNetworkPredictionArrayToDataPredictionArray(predictions) ?? []
            }
            .eraseToAnyPublisher()
    }
}