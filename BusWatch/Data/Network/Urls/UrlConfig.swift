//
//  UrlConfig.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

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
