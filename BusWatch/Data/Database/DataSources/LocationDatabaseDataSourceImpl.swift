//
//  LocationDatabaseDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class LocationDatabaseDataSourceImpl: LocationDatabaseDataSource {

    private enum Error: Swift.Error {
        case locationBoundsNotFound(String)
    }

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func getLastLocationBounds() -> AnyPublisher<LocationBounds, Swift.Error> {
        let sql = "SELECT * FROM \(LastLocationTable.tableName)"
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql)
                    guard let lastLocation = row?.toLocationBounds() else {
                        throw LocationDatabaseDataSourceImpl.Error.locationBoundsNotFound("")
                    }
                    return lastLocation
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func saveLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Swift.Error> {
        let sql = """
        INSERT INTO \(LastLocationTable.tableName) (\(LastLocationTable.allColumns))
        VALUES (1, ?, ?, ?, ?) ON CONFLICT (\(LastLocationTable.idColumn))
        DO UPDATE SET
        \(LastLocationTable.northBoundColumn) = ?,
        \(LastLocationTable.southBoundColumn) = ?,
        \(LastLocationTable.westBoundColumn) = ?,
        \(LastLocationTable.eastBoundColumn) = ?
        """

        let arguments = StatementArguments([
            locationBounds.north.description,
            locationBounds.south.description,
            locationBounds.west.description,
            locationBounds.east.description,
            locationBounds.north.description,
            locationBounds.south.description,
            locationBounds.west.description,
            locationBounds.east.description
        ])
        return database.queue
            .flatMap { dbQueue in
                return dbQueue.writePublisher { db in
                    try db.execute(sql: sql, arguments: arguments)
                }
            }
            .eraseToAnyPublisher()
    }
}
