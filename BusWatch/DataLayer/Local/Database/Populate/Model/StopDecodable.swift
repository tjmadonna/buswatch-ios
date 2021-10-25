//
//  StopDecodable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct StopDecodable: Decodable {

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

    var arguments: StatementArguments? {
        if let id = id, let title = title, let latitude = latitude, let longitude = longitude, let routes = routes {
            return StatementArguments([
                StopsTable.IDColumn: id,
                StopsTable.TitleColumn: title,
                StopsTable.LatitudeColumn: latitude,
                StopsTable.LongitudeColumn: longitude,
                StopsTable.RoutesColumn: routes.joined(separator: StopsTableMapper.RoutesDelimiter)
            ])
        } else {
            return nil
        }
    }

    func mapToStop() -> Stop? {
        guard let id = id,
            let title = title,
            let latitude = latitude,
            let longitude = longitude,
            let routes = routes else {
                return nil
        }
        return Stop(id: id, title: title, favorite: false, latitude: latitude, longitude: longitude, routes: routes)
    }
}
