//
//  UrlSource.swift
//  Network
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

protocol UrlSource {

    func authenticatedPredictionsURLForStopId(_ stopId: String) -> URL

}

struct UrlConfig {

    let scheme: String

    let host: String

    let apiKey: String

    let basePath: String

    init(scheme: String, host: String, apiKey: String, basePath: String) {
        self.scheme = scheme
        self.host = host
        self.apiKey = apiKey
        self.basePath = basePath
    }
}

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
