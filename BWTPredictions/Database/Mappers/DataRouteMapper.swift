//
//  DataRouteMapper.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB
import BWTDatabase

public final class DataRouteMapper {

    public init() { }

    func mapDatabaseCursorToDataRouteArray(_ cursor: RowCursor) -> [DataRoute] {
        var routes = [DataRoute]()
        while let cursorRow = try? cursor.next() {
            if let route = mapDatabaseRowToDataRoute(cursorRow) {
                routes.append(route)
            }
        }
        return routes
    }

    func mapDatabaseRowToDataRoute(_ row: Row?) -> DataRoute? {
        guard let row = row else { return nil }
        guard let id = row[RoutesTable.idColumn] as? String else { return nil }
        guard let title = row[RoutesTable.titleColumn] as? String else { return nil }
        guard let color = row[RoutesTable.colorColumn] as? String else { return nil }

        return DataRoute(
            id: id,
            title: title,
            color: color
        )
    }
}
