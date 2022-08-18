//
//  DbRoute.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct DbRoute {
    let id: String
    let title: String
}

extension DbRoute: Codable {

}

extension DbRoute: FetchableRecord {

}
