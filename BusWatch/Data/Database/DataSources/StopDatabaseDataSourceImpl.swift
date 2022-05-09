//
//  StopDatabaseDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
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
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), f.\(FavoriteStopsTable.stopIdColumn)
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
        let sql = """
        INSERT OR IGNORE INTO \(FavoriteStopsTable.tableName)
        (\(FavoriteStopsTable.stopIdColumn)) VALUES (?)
        """

        return writePublisherForSql(sql, arguments: [stopId])
    }

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error> {
        let sql = """
        DELETE FROM \(FavoriteStopsTable.tableName)
        WHERE \(FavoriteStopsTable.stopIdColumn) = ?
        """

        return writePublisherForSql(sql, arguments: [stopId])
    }

    func getStopsInLocationBounds(_ locationBounds: LocationBounds)
        -> AnyPublisher<[DatabaseDetailedStop], Swift.Error> {

        let sql = """
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), s.\(StopsTable.serviceTypeColumn),
        s.\(StopsTable.latitudeColumn), s.\(StopsTable.longitudeColumn),
        s.\(StopsTable.routesColumn), e.\(ExcludedRoutesTable.routesColumn) AS \(ExcludedRoutesTable.routesColumnAlt)
        FROM \(StopsTable.tableName) AS s
        LEFT JOIN \(ExcludedRoutesTable.tableName) AS e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
        WHERE s.\(StopsTable.latitudeColumn) <= ?
        AND s.\(StopsTable.latitudeColumn) >= ?
        AND s.\(StopsTable.longitudeColumn) >= ?
        AND s.\(StopsTable.longitudeColumn) <= ?
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
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), s.\(StopsTable.serviceTypeColumn),
        s.\(StopsTable.routesColumn), e.\(ExcludedRoutesTable.routesColumn) AS \(ExcludedRoutesTable.routesColumnAlt)
        FROM \(StopsTable.tableName) AS s
        INNER JOIN \(FavoriteStopsTable.tableName) AS f
        ON s.\(StopsTable.idColumn) = f.\(FavoriteStopsTable.stopIdColumn)
        LEFT JOIN \(ExcludedRoutesTable.tableName) as e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
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
                do {
                    try db.execute(sql: sql, arguments: arguments)
                } catch {
                    print(error)
                    throw error
                }
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
                    do {
                        let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
                        return cursor.compactMap(rowMapper)
                    } catch {
                        print(error)
                        throw error
                    }
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }
}
