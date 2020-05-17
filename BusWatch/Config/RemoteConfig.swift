//
//  RemoteConfig.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/2/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

enum NetworkConfig {

    private static let host = "REST_API_HOST"

    private static let apiKey = "REST_API_KEY"

    // MARK: - Predictions

    static func authenticatedURLPredictionsForStopId(_ stopId: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = NetworkConfig.host
        components.path = "/predictions/\(stopId)"
        components.queryItems = [ URLQueryItem(name: "key", value: NetworkConfig.apiKey) ]
        guard let url = components.url else {
            fatalError("NetworkConfig Error: Cannot create a valid authenticatedURLPredictionsForStopId")
        }
        return url
    }
}
