//
//  StopDatabaseDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class StopDatabaseDataSourceImpl: StopDatabaseDataSource {

    private enum Error: Swift.Error {
        case stopNotFound(String)
    }

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func getStopById(_ stopId: String) -> AnyPublisher<MinimalStop, Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), \(FavoriteStopsTable.stopIdColumn)
        FROM \(StopsTable.tableName) AS s
        LEFT JOIN \(FavoriteStopsTable.tableName) AS f
        ON s.\(StopsTable.idColumn) = f.\(FavoriteStopsTable.stopIdColumn)
        WHERE s.\(StopsTable.idColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
                    guard let stop = row?.toMinimalStop() else {
                        throw StopDatabaseDataSourceImpl.Error.stopNotFound("")
                    }
                    return stop
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error> {
        let sql = "INSERT INTO \(FavoriteStopsTable.tableName) ( \(FavoriteStopsTable.stopIdColumn) ) VALUES ( ? )"
        return writePublisherForSql(sql, arguments: [stopId])
    }

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error> {
        let sql = "DELETE FROM \(FavoriteStopsTable.tableName) WHERE \(FavoriteStopsTable.stopIdColumn) = ?"
        return writePublisherForSql(sql, arguments: [stopId])
    }

    func getStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[DetailedStop], Swift.Error> {
        let sql = """
        SELECT *
        FROM \(StopsTable.tableName)
        WHERE \(StopsTable.latitudeColumn) <= ?
        AND \(StopsTable.latitudeColumn) >= ?
        AND \(StopsTable.longitudeColumn) >= ?
        AND \(StopsTable.longitudeColumn) <= ?
        """
        let arguments = StatementArguments([locationBounds.north,
                                            locationBounds.south,
                                            locationBounds.west,
                                            locationBounds.east])
        return valueObservationPublisherForSql(sql, arguments: arguments) { row in
            row.toDetailedStop()
        }
    }

    func getFavoriteStops() -> AnyPublisher<[FavoriteStop], Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), s.\(StopsTable.routesColumn),
        e.\(ExcludedRoutesTable.routesColumn) as "e.\(ExcludedRoutesTable.routesColumn)"
        FROM \(StopsTable.tableName) AS s
        INNER JOIN \(FavoriteStopsTable.tableName) AS f
        ON s.\(StopsTable.idColumn) = f.\(FavoriteStopsTable.stopIdColumn)
        LEFT JOIN \(ExcludedRoutesTable.tableName) as e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
        """
        return valueObservationPublisherForSql(sql) { row in
            row.toFavoriteStop()
        }
    }

    // MARK: - Helper functions

    private func writePublisherForSql(_ sql: String, arguments: StatementArguments) -> AnyPublisher<Void, Swift.Error> {
        return database.queue
            .flatMap { dbQueue in
                return dbQueue.writePublisher { db in
                    try db.execute(sql: sql, arguments: arguments)
                }
            }
            .first()
            .eraseToAnyPublisher()
    }

    private func valueObservationPublisherForSql<T>(_ sql: String,
                                                    arguments: StatementArguments = StatementArguments(),
                                                    rowMapper: @escaping (Row) -> T?)
        -> AnyPublisher<[T], Swift.Error> {

        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
                    return cursor.compactMap(rowMapper)
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }
}
