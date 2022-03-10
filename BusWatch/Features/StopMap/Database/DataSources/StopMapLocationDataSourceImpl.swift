//
//  StopMapLocationDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class StopMapLocationDataSourceImpl: StopMapLocationDataSource {

    private enum Error: Swift.Error {
        case locationBoundsNotFound
    }

    private let database: DatabaseDataSource

    private let mapper: StopMapLocationMapper

    init(database: DatabaseDataSource, mapper: StopMapLocationMapper = StopMapLocationMapper()) {
        self.database = database
        self.mapper = mapper
    }

    // MARK: - StopMapLocationDataSource

    func getLastLocationBounds() -> AnyPublisher<StopMapLocationBounds, Swift.Error> {
        let sql = "SELECT * FROM \(LastLocationTable.tableName)"
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql)
                    guard let lastLocation = self.mapper.mapDatabaseRowToDomainLocationBounds(row) else {
                        throw StopMapLocationDataSourceImpl.Error.locationBoundsNotFound
                    }
                    return lastLocation
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func saveLastLocationBounds(_ locationBounds: StopMapLocationBounds) -> AnyPublisher<Void, Swift.Error> {
        let sql = """
        INSERT INTO \(LastLocationTable.tableName) (\(LastLocationTable.allColumns))
        VALUES (?, ?, ?, ?, ?) ON CONFLICT(\(LastLocationTable.idColumn))
        DO UPDATE SET
        \(LastLocationTable.northBoundColumn) = ?,
        \(LastLocationTable.southBoundColumn) = ?,
        \(LastLocationTable.westBoundColumn) = ?,
        \(LastLocationTable.eastBoundColumn) = ?
        """

        let arguments = StatementArguments([
            1.description,
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
