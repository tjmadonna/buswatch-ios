//
//  RouteDatabaseDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class RouteDatabaseDataSourceImpl: RouteDatabaseDataSource {

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func getFilterableRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterableRoute], Swift.Error> {
        let sql = """
        SELECT
        s.\(StopsTable.routesColumn) AS \(StopsTable.tableName)_\(StopsTable.routesColumn),
        e.\(ExcludedRoutesTable.routesColumn) AS \(ExcludedRoutesTable.tableName)_\(ExcludedRoutesTable.routesColumn)
        FROM \(StopsTable.tableName) AS s
        LEFT JOIN \(ExcludedRoutesTable.tableName) AS e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
        WHERE s.\(StopsTable.idColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
                    return row?.toFilterableRoute() ?? []
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func getRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[DatabaseRoute], Swift.Error> {
        let idSet = Set(routeIds)
        let placeHolderString = Array(repeating: "?", count: idSet.count).joined(separator: ", ")
        let sql = """
        SELECT \(RoutesTable.idColumn), \(RoutesTable.titleColumn)
        FROM \(RoutesTable.tableName)
        WHERE \(RoutesTable.idColumn) IN (\(placeHolderString))
        """
        let arguments = StatementArguments(Array(idSet))
        return database.queue
            .tryMap { dbQueue in
                return try dbQueue.read { db in
                    let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
                    return cursor.compactMap { row in
                        row.toDatabaseRoute()
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    func getFilteredRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Swift.Error> {
        let sql = """
        SELECT \(ExcludedRoutesTable.routesColumn) FROM \(ExcludedRoutesTable.tableName)
        WHERE \(ExcludedRoutesTable.stopIdColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
                    return row?.toFilteredRouteIds() ?? []
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Swift.Error> {
        let sql = """
        INSERT INTO \(ExcludedRoutesTable.tableName) (\(ExcludedRoutesTable.allColumns))
        VALUES (?, ?) ON CONFLICT (\(ExcludedRoutesTable.stopIdColumn))
        DO UPDATE SET
        \(ExcludedRoutesTable.stopIdColumn) = ?,
        \(ExcludedRoutesTable.routesColumn) = ?
        """

        let routeIdString = routeIds.joined(separator: ExcludedRoutesTable.routesDelimiter)
        let arguments = StatementArguments([
            stopId,
            routeIdString,
            stopId,
            routeIdString
        ])

        return database.queue
            .flatMap { dbQueue in
                return dbQueue.writePublisher { db in
                    try db.execute(sql: sql, arguments: arguments)
                }
            }
            .first()
            .eraseToAnyPublisher()
    }
}
