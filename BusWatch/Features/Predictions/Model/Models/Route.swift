//
//  Route.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct Route {
    let id: String
    let title: String
}

extension Route: Identifiable {

}

extension Route: Equatable {

    static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title
    }

}

extension Route: GRDB.FetchableRecord  {

    init(row: GRDB.Row) {
        let id = row[RoutesTable.idColumn] as String
        let title = row[RoutesTable.titleColumn] as String

        self.init(id: id, title: title)
    }

}
