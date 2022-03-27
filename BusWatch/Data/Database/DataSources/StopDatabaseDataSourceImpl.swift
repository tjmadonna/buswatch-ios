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
        SELECT \(StopsTable.idColumn), \(StopsTable.titleColumn), \(StopsTable.favoriteColumn)
        FROM \(StopsTable.tableName)
        WHERE \(StopsTable.idColumn) = ?
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
        let sql = """
        UPDATE \(StopsTable.tableName)
        SET \(StopsTable.favoriteColumn) = 1
        WHERE \(StopsTable.idColumn) = ?;
        """
        return writePublisherForSql(sql, arguments: [stopId])
    }

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error> {
        let sql = """
        UPDATE \(StopsTable.tableName)
        SET \(StopsTable.favoriteColumn) = 0
        WHERE \(StopsTable.idColumn) = ?;
        """
        return writePublisherForSql(sql, arguments: [stopId])
    }

    func getStopsInLocationBounds(_ locationBounds: LocationBounds)
        -> AnyPublisher<[DatabaseDetailedStop], Swift.Error> {

        let sql = """
        SELECT \(StopsTable.idColumn), \(StopsTable.titleColumn),
        \(StopsTable.latitudeColumn), \(StopsTable.longitudeColumn),
        \(StopsTable.routesColumn), \(StopsTable.excludedRoutesColumn)
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
            row.toDatabaseDetailedStop()
        }
    }

    func getFavoriteStops() -> AnyPublisher<[DatabaseFavoriteStop], Swift.Error> {
        let sql = """
        SELECT \(StopsTable.idColumn), \(StopsTable.titleColumn),
        \(StopsTable.routesColumn), \(StopsTable.excludedRoutesColumn)
        FROM \(StopsTable.tableName)
        WHERE \(StopsTable.favoriteColumn) = 1
        """
        return valueObservationPublisherForSql(sql) { row in
            row.toDatabaseFavoriteStop()
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
