//
//  DecodableRoute.swift
//  Database
//
//  Created by Tyler Madonna on 11/6/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct DecodableRoute: Decodable {

    let id: String?

    let title: String?

    let color: String?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case color = "color"
    }

//    var arguments: StatementArguments? {
//        if let id = id, let title = title, let color = color {
//            return StatementArguments([
//                RoutesTable.IDColumn: id,
//                RoutesTable.TitleColumn: title,
//                RoutesTable.ColorColumn: color
//            ])
//        } else {
//            return nil
//        }
//    }
}
