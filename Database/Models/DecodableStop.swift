//
//  DecodableStop.swift
//  Database
//
//  Created by Tyler Madonna on 11/4/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct DecodableStop: Decodable {

    let id: String?

    let title: String?

    let latitude: Double?

    let longitude: Double?

    let routes: [String]?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case latitude = "latitude"
        case longitude = "longitude"
        case routes = "routes"
    }
}
