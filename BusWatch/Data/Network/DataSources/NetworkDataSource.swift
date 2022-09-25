//
//  NetworkDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation

protocol NetworkDataSource {

    func observePredictionsForStopId(_ stopId: String, serviceType: ServiceType, updateInterval: TimeInterval)
        -> AnyPublisher<LoadingResponse<[NetworkPrediction]>, Error>

}

final class NetworkDataSourceImpl: NetworkDataSource {

    private let urlSource: UrlSource

    private let urlSession: URLSession

    init(urlSource: UrlSource, urlSession: URLSession = URLSession.shared) {
        self.urlSource = urlSource
        self.urlSession = urlSession
    }

    func observePredictionsForStopId(_ stopId: String, serviceType: ServiceType, updateInterval: TimeInterval)
        -> AnyPublisher<LoadingResponse<[NetworkPrediction]>, Error> {

        let url = urlSource.authenticatedPredictionsURLForStopId(stopId, serviceType: serviceType)
        return TimedNetworkPublisher<NetworkGetPredictionsResponse>(url: url,
                                                                    timeInterval: updateInterval,
                                                                    urlSession: urlSession)
            .map { [unowned self] response in
                self.tryToMapNetworkResponse(response)
            }
            .eraseToAnyPublisher()
    }

    private func tryToMapNetworkResponse(_ response: LoadingResponse<NetworkGetPredictionsResponse>)
        -> LoadingResponse<[NetworkPrediction]> {

            switch response {
            case .loading:
                return .loading
            case .success(let res):
                let predictions = res.bustimeResponse?.predictions ?? []
                return .success(predictions)
            case .failure(let error):
                return .failure(error)
            }
    }

}
