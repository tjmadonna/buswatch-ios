//
//  LocationDbDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import GRDB

protocol LocationDbDataSource {

    func observeLastLocationBounds() -> AnyPublisher<DbLocationBounds, Swift.Error>
    func insertLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Swift.Error>

}

final class LocationDbDataSourceImpl: LocationDbDataSource {

    private enum Error: Swift.Error {
        case locationBoundsNotFound(String)
    }

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func observeLastLocationBounds() -> AnyPublisher<DbLocationBounds, Swift.Error> {
        let sql = "SELECT * FROM \(LastLocationTable.tableName)"
        return database.queuePublisher
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    guard let lastLocation = try DbLocationBounds.fetchOne(db, sql: sql) else {
                        throw LocationDbDataSourceImpl.Error.locationBoundsNotFound("Last location not found")
                    }
                    return lastLocation
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func insertLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Swift.Error> {
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
        return database.queuePublisher
            .flatMap { dbQueue in
                return dbQueue.writePublisher { db in
                    try db.execute(sql: sql, arguments: arguments)
                }
            }
            .eraseToAnyPublisher()
    }

}
