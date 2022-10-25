//
//  AppComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class AppComponent {

    let database: DatabaseConformable

    init() throws {
        self.database = try Database()
    }

    lazy var urlSource: UrlSourceConformable = {
        let config = UrlConfig(scheme: NetworkConfig.scheme,
                               host: NetworkConfig.host,
                               apiKey: NetworkConfig.apiKey,
                               basePath: NetworkConfig.basePath)
        return UrlSource(urlConfig: config)
    }()

    lazy var urlSession: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        return URLSession(configuration: sessionConfig)
    }()

    var userDefaults: UserDefaults {
        return .standard
    }

}
