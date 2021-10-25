//
//  RoutesTableMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

enum RoutesTableMapper {

    static func mapCursorToRoute(_ cursor: RowCursor) -> [Route] {
        var routes = [Route]()
        while let cursorRow = try? cursor.next() {
            if let route = mapCursorRowToRoute(cursorRow) {
                routes.append(route)
            }
        }
        return routes
    }

    static func mapCursorRowToRoute(_ row: Row?) -> Route? {
        guard let row = row else { return nil }
        guard let id = row[RoutesTable.IDColumn] as? String else { return nil }
        guard let title = row[RoutesTable.TitleColumn] as? String else { return nil }
        guard let color = row[RoutesTable.ColorColumn] as? String else { return nil }

        return Route(
            id: id,
            title: title,
            color: color
        )
    }
}
