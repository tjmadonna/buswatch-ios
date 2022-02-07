//
//  OverviewFavoriteStopMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class OverviewFavoriteStopMapper {

    func mapDatabaseCursorToDomainFavoriteStopArray(_ cursor: RowCursor) -> [OverviewFavoriteStop] {
        var favoriteStops = [OverviewFavoriteStop]()
        while let cursorRow = try? cursor.next() {
            if let favoriteStop = mapDatabaseRowToDomainFavoriteStop(cursorRow) {
                favoriteStops.append(favoriteStop)
            }
        }
        return favoriteStops
    }

    func mapDatabaseRowToDomainFavoriteStop(_ row: Row?) -> OverviewFavoriteStop? {
        guard let row = row else { return nil }
        guard let id = row[StopsTable.idColumn] as? String else { return nil }
        guard let title = row[StopsTable.titleColumn] as? String else { return nil }

        let excludedRoutesString = row["e.\(ExcludedRoutesTable.routesColumn)"] as? String ?? ""
        let excludedRoutes = Set(excludedRoutesString.components(separatedBy: ExcludedRoutesTable.routesDelimiter))

        let routesString = row[StopsTable.routesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTable.routesDelimiter)
            .filter { route in !excludedRoutes.contains(route) }

        return OverviewFavoriteStop(id: id, title: title, routes: routes)
    }
}
