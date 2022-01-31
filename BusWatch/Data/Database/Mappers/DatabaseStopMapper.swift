//
//  DatabaseStopMapper.swift
//  Database
//
//  Created by Tyler Madonna on 11/6/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class DatabaseStopMapper {

    init() { }

    // MARK: - Database cursor

    func mapDatabaseCursorToDatabaseStopArray(_ cursor: RowCursor) -> [DatabaseStop] {
        var stops = [DatabaseStop]()
        while let cursorRow = try? cursor.next() {
            if let stop = mapDatabaseRowToDatabaseStop(cursorRow) {
                stops.append(stop)
            }
        }
        return stops
    }

    func mapDatabaseRowToDatabaseStop(_ row: Row?) -> DatabaseStop? {
        guard let row = row else { return nil }
        guard let id = row[StopsTable.idColumn] as? String else { return nil }
        guard let title = row[StopsTable.titleColumn] as? String else { return nil }
        guard let latitude = row[StopsTable.latitudeColumn] as? Double else { return nil }
        guard let longitude = row[StopsTable.longitudeColumn] as? Double else { return nil }

        let routesString = row[StopsTable.routesColumn] as? String ?? ""
        let routes = routesString.components(separatedBy: StopsTable.routesDelimiter)

        return DatabaseStop(
            id: id,
            title: title,
            latitude: latitude,
            longitude: longitude,
            routes: routes
        )
    }

    func mapDatabaseStopToStatementArguments(_ stop: DatabaseStop) -> StatementArguments {
        return StatementArguments([
            StopsTable.idColumn: stop.id,
            StopsTable.titleColumn: stop.title,
            StopsTable.latitudeColumn: stop.latitude,
            StopsTable.longitudeColumn: stop.longitude,
            StopsTable.routesColumn: stop.routes.joined(separator: StopsTable.routesDelimiter)
        ])
    }

    // MARK: - Decodable

    func mapDecodableStopArrayToDatabaseStopArray(_ decodableStops: [DecodableStop]?) -> [DatabaseStop] {
        guard let decodableStops = decodableStops else { return [] }
        return decodableStops.compactMap { mapDecodableStopToDatabaseStop($0) }
    }

    func mapDecodableStopToDatabaseStop(_ decodableStop: DecodableStop?) -> DatabaseStop? {
        guard let decodableStop = decodableStop else { return nil }
        guard let id = decodableStop.id else { return nil }
        guard let title = decodableStop.title else { return nil }
        guard let latitude = decodableStop.latitude else { return nil }
        guard let longitude = decodableStop.longitude else { return nil }
        guard let routes = decodableStop.routes else { return nil }

        return DatabaseStop(
            id: id,
            title: title,
            latitude: latitude,
            longitude: longitude,
            routes: routes
        )
    }
}
