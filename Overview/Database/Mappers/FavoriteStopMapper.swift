//
//  FavoriteStopMapper.swift
//  Overview
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB
import Database
import CloudKit

public final class FavoriteStopMapper {

    public init() { }

    func mapDatabaseCursorToDomainFavoriteStopArray(_ cursor: RowCursor) -> [FavoriteStop] {
        var favoriteStops = [FavoriteStop]()
        while let cursorRow = try? cursor.next() {
            if let favoriteStop = mapDatabaseRowToDomainFavoriteStop(cursorRow) {
                favoriteStops.append(favoriteStop)
            }
        }
        return favoriteStops
    }

    func mapDatabaseRowToDomainFavoriteStop(_ row: Row?) -> FavoriteStop? {
        guard let row = row else { return nil }
        guard let id = row[StopsTable.idColumn] as? String else { return nil }
        guard let title = row[StopsTable.titleColumn] as? String else { return nil }

        let routesString = row[StopsTable.routesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTable.routesDelimiter)

        return FavoriteStop(id: id, title: title, routes: routes)
    }
}
