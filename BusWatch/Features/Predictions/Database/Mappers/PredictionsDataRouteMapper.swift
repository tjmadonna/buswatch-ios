//
//  PredictionsDataRouteMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class PredictionsDataRouteMapper {

    func mapDatabaseCursorToDataRouteArray(_ cursor: RowCursor) -> [PredictionsDataRoute] {
        var routes = [PredictionsDataRoute]()
        while let cursorRow = try? cursor.next() {
            if let route = mapDatabaseRowToDataRoute(cursorRow) {
                routes.append(route)
            }
        }
        return routes
    }

    func mapDatabaseRowToDataRoute(_ row: Row?) -> PredictionsDataRoute? {
        guard let row = row else { return nil }
        guard let id = row[RoutesTable.idColumn] as? String else { return nil }
        guard let title = row[RoutesTable.titleColumn] as? String else { return nil }
        guard let color = row[RoutesTable.colorColumn] as? String else { return nil }

        return PredictionsDataRoute(
            id: id,
            title: title,
            color: color
        )
    }
}
