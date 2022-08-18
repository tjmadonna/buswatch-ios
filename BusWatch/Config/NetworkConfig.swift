//
//  RemoteConfig.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/2/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

enum NetworkConfig {

    static let scheme = "https"

    static let host = "truetime.portauthority.org"

    static let apiKey = Secrets.apiKey

    static let basePath = "/bustime/api/v3"

}
