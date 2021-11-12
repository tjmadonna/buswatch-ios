//
//  PredictionDataSource.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import Network

public final class PredictionDataSource : PredictionDataSourceRepresentable {

    private let urlSource: UrlSourceRepresentable

    private let urlSession: URLSession

    private let mapper: DataPredictionMapper

    public init(urlSource: UrlSourceRepresentable,
                urlSession: URLSession = URLSession.shared,
                mapper: DataPredictionMapper = DataPredictionMapper()) {
        self.urlSource = urlSource
        self.urlSession = urlSession
        self.mapper = mapper
    }

    // MARK: - PredictionDataSourceRepresentable

    public func getPredictionsForStopId(_ stopId: String) -> AnyPublisher<[DataPrediction], Error> {
        let url = urlSource.authenticatedPredictionsURLForStopId(stopId)
        return TimedNetworkPublisher<NetworkGetPredictionsResponse>(url: url, timeInterval: 30, urlSession: self.urlSession)
            .map { response in response.bustimeResponse?.predictions ?? [] }
            .map { [weak self] predictions in self?.mapper.mapNetworkPredictionArrayToDataPredictionArray(predictions) ?? [] }
            .eraseToAnyPublisher()
    }
}
