//
//  StopsTableMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import GRDB

enum StopsTableMapper {

    static let RoutesDelimiter: String = ","

    static func mapCursorToStopList(_ cursor: RowCursor) -> [Stop] {
        var stops = [Stop]()
        while let cursorRow = try? cursor.next() {
            if let stop = mapCursorRowToStop(cursorRow) {
                stops.append(stop)
            }
        }
        return stops
    }

    static func mapCursorRowToStop(_ row: Row?) -> Stop? {
        guard let row = row else { return nil }
        guard let id = row[StopsTable.IDColumn] as? String else { return nil }
        guard let title = row[StopsTable.TitleColumn] as? String else { return nil }
        guard let latitude = row[StopsTable.LatitudeColumn] as? Double else { return nil }
        guard let longitude = row[StopsTable.LongitudeColumn] as? Double else { return nil }

        let favorite = row[FavoriteStopsTable.StopIdColumn] != nil

        let routesString = row[StopsTable.RoutesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTableMapper.RoutesDelimiter)

        return Stop(
            id: id,
            title: title,
            favorite: favorite,
            latitude: latitude,
            longitude: longitude,
            routes: routes
        )
    }

    static func mapStopToArguments(_ stop: Stop) -> StatementArguments {
        return StatementArguments([
            StopsTable.IDColumn: stop.id,
            StopsTable.TitleColumn: stop.title,
            StopsTable.LatitudeColumn: stop.latitude,
            StopsTable.LongitudeColumn: stop.longitude,
            StopsTable.RoutesColumn: stop.routes.joined(separator: StopsTableMapper.RoutesDelimiter)
        ])
    }
}
