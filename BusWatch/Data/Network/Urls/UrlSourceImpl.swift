//
//  UrlSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

final class UrlSourceImpl: UrlSource {

    private let urlConfig: UrlConfig

    init(urlConfig: UrlConfig) {
        self.urlConfig = urlConfig
    }

    // MARK: - Predictions

    func authenticatedPredictionsURLForStopId(_ stopId: String) -> URL {
        var components = URLComponents()
        components.scheme = urlConfig.scheme
        components.host = urlConfig.host
        components.path = "\(urlConfig.basePath)/getpredictions"
        components.queryItems = [
            URLQueryItem(name: "key", value: urlConfig.apiKey),
            URLQueryItem(name: "stpid", value: stopId),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "rtpidatafeed", value: "Port Authority Bus".removingPercentEncoding!)
        ]
        guard let url = components.url else {
            fatalError("Cannot create a valid authenticatedURLPredictionsForStopId")
        }
        return url
    }
}
