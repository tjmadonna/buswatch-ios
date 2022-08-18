//
//  StopDbDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import GRDB

protocol StopDbDataSource {

    func observeStopById(_ stopId: String) -> AnyPublisher<DbMinimalStop, Swift.Error>
    func insertFavoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error>
    func deleteFavoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error>
    func observeStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[DbDetailedStop], Swift.Error>
    func observeFavoriteStops() -> AnyPublisher<[DbFavoriteStop], Swift.Error>

}

final class StopDbDataSourceImpl: StopDbDataSource {

    private enum Error: Swift.Error {
        case stopNotFound(String)
    }

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func observeStopById(_ stopId: String) -> AnyPublisher<DbMinimalStop, Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), f.\(FavoriteStopsTable.stopIdColumn)
        FROM \(StopsTable.tableName) AS s
        LEFT JOIN \(FavoriteStopsTable.tableName) AS f
        ON s.\(StopsTable.idColumn) = f.\(FavoriteStopsTable.stopIdColumn)
        WHERE s.\(StopsTable.idColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queuePublisher
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    guard let stop = try DbMinimalStop.fetchOne(db, sql: sql, arguments: arguments) else {
                        throw StopDbDataSourceImpl.Error.stopNotFound("Stop with id \(stopId) not found")
                    }
                    return stop
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func insertFavoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error> {
        let sql = """
        INSERT OR IGNORE INTO \(FavoriteStopsTable.tableName)
        (\(FavoriteStopsTable.stopIdColumn)) VALUES (?)
        """
        return writePublisherForSql(sql, arguments: [stopId])
    }

    func deleteFavoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error> {
        let sql = """
        DELETE FROM \(FavoriteStopsTable.tableName)
        WHERE \(FavoriteStopsTable.stopIdColumn) = ?
        """

        return writePublisherForSql(sql, arguments: [stopId])
    }

    func observeStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[DbDetailedStop], Swift.Error> {
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
        return valueObservationPublisherForSql(sql, arguments: arguments)
    }

    func observeFavoriteStops() -> AnyPublisher<[DbFavoriteStop], Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), s.\(StopsTable.serviceTypeColumn),
        s.\(StopsTable.routesColumn), e.\(ExcludedRoutesTable.routesColumn) AS \(ExcludedRoutesTable.routesColumnAlt)
        FROM \(StopsTable.tableName) AS s
        INNER JOIN \(FavoriteStopsTable.tableName) AS f
        ON s.\(StopsTable.idColumn) = f.\(FavoriteStopsTable.stopIdColumn)
        LEFT JOIN \(ExcludedRoutesTable.tableName) as e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
        """
        return valueObservationPublisherForSql(sql)
    }

    // MARK: - Helper functions

    private func writePublisherForSql(
        _ sql: String,
        arguments: StatementArguments
    ) -> AnyPublisher<Void, Swift.Error> {

        return database.queuePublisher
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

    private func valueObservationPublisherForSql<T: FetchableRecord>(
        _ sql: String,
        arguments: StatementArguments = StatementArguments()
    )-> AnyPublisher<[T], Swift.Error> {

        return database.queuePublisher
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    do {
                        return try T.fetchAll(db, sql: sql, arguments: arguments)
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
