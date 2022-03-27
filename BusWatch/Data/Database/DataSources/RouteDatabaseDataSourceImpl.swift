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

    private enum Error: Swift.Error {
        case stopNotFound(String)
    }

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func getDatabaseRoutesWithExclusionsForStopId(_ stopId: String)
        -> AnyPublisher<DatabaseRoutesWithExclusions, Swift.Error> {

        let sql = """
        SELECT \(StopsTable.routesColumn), \(StopsTable.excludedRoutesColumn)
        FROM \(StopsTable.tableName)
        WHERE \(StopsTable.idColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
                    guard let routes = row?.toDatabaseRoutesWithExclusions() else {
                        throw RouteDatabaseDataSourceImpl.Error.stopNotFound("")
                    }
                    return routes
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

    func getExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Swift.Error> {
        let sql = """
        SELECT \(StopsTable.excludedRoutesColumn) FROM \(StopsTable.tableName)
        WHERE \(StopsTable.idColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
                    return row?.toExcludedRouteIds() ?? []
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Swift.Error> {
        let sql = """
        UPDATE \(StopsTable.tableName)
        SET \(StopsTable.excludedRoutesColumn) = ?
        WHERE \(StopsTable.idColumn) = ?
        """
        let routeIdString = routeIds.joined(separator: StopsTable.routesDelimiter)
        let arguments = StatementArguments([routeIdString, stopId])

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
