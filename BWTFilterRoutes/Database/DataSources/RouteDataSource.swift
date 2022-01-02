//
//  RouteDataSource.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB
import BWTDatabase

public final class RouteDataSource : RouteDataSourceRepresentable {

    private enum Error: Swift.Error {
        case routesNotFound
    }

    private let database: DatabaseDataSourceRepresentable

    private let routeMapper: RouteMapper

    public init(database: DatabaseDataSourceRepresentable, routeMapper: RouteMapper = RouteMapper()) {
        self.database = database
        self.routeMapper = routeMapper
    }

    public func getRoutesForStopId(_ stopId: String) -> AnyPublisher<[Route], Swift.Error> {
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
                    guard let routes = self.routeMapper.mapDatabaseRowToRoutesArray(row) else {
                        throw RouteDataSource.Error.routesNotFound
                    }
                    return routes
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    public func updateExcludedRoutes(_ routeIds: [String], stopId: String) -> AnyPublisher<Void, Swift.Error> {
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
