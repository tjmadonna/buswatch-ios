//
//  RouteDbDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import GRDB

protocol RouteDbDataSource {

    func observeDbRoutesWithExcludedForStopId(_ stopId: String) -> AnyPublisher<DbRoutesWithExcluded, Swift.Error>
    func observeRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[DbRoute], Swift.Error>
    func observeExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Swift.Error>
    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Swift.Error>

}

final class RouteDbDataSourceImpl: RouteDbDataSource {

    private enum Error: Swift.Error {
        case stopNotFound(String)
    }

    private let database: Database

    init(database: Database) {
        self.database = database
    }

    func observeDbRoutesWithExcludedForStopId(_ stopId: String) -> AnyPublisher<DbRoutesWithExcluded, Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.routesColumn), e.\(ExcludedRoutesTable.routesColumn)
        AS \(ExcludedRoutesTable.routesColumnAlt)
        FROM \(StopsTable.tableName) AS s
        LEFT JOIN \(ExcludedRoutesTable.tableName) AS e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
        WHERE s.\(StopsTable.idColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queuePublisher
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    guard let routes = try DbRoutesWithExcluded.fetchOne(db, sql: sql, arguments: arguments) else {
                        throw RouteDbDataSourceImpl.Error.stopNotFound("Stop with id \(stopId) not found")
                    }
                    return routes
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func observeRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[DbRoute], Swift.Error> {
        let idSet = Set(routeIds)
        let placeHolderString = Array(repeating: "?", count: idSet.count).joined(separator: ", ")
        let sql = """
        SELECT \(RoutesTable.idColumn), \(RoutesTable.titleColumn)
        FROM \(RoutesTable.tableName)
        WHERE \(RoutesTable.idColumn) IN (\(placeHolderString))
        """
        let arguments = StatementArguments(Array(idSet))
        return database.queuePublisher
            .tryMap { dbQueue in
                return try dbQueue.read { db in
                    return try DbRoute.fetchAll(db, sql: sql, arguments: arguments)
                }
            }
            .eraseToAnyPublisher()
    }

    func observeExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Swift.Error> {
        let sql = """
        SELECT \(ExcludedRoutesTable.routesColumn) FROM \(ExcludedRoutesTable.tableName)
        WHERE \(ExcludedRoutesTable.stopIdColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queuePublisher
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    return try String.fetchOne(db, sql: sql, arguments: arguments)?
                        .components(separatedBy: ExcludedRoutesTable.routesDelimiter) ?? []
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) -> AnyPublisher<Void, Swift.Error> {
        let sql: String
        let arguments: StatementArguments

        if routeIds.isEmpty {
            sql = "DELETE FROM \(ExcludedRoutesTable.tableName) WHERE \(ExcludedRoutesTable.stopIdColumn) = ?"
            arguments = StatementArguments([stopId])
        } else {
            sql = """
                  INSERT INTO \(ExcludedRoutesTable.tableName)
                  (\(ExcludedRoutesTable.stopIdColumn), \(ExcludedRoutesTable.routesColumn))
                  VALUES (?, ?) ON CONFLICT (\(ExcludedRoutesTable.stopIdColumn))
                  DO UPDATE SET \(ExcludedRoutesTable.routesColumn) = ?
                  """
            let routeIdString = routeIds.joined(separator: ExcludedRoutesTable.routesDelimiter)
            arguments = StatementArguments([stopId, routeIdString, routeIdString])
        }

        return database.queuePublisher
            .flatMap { dbQueue in
                return dbQueue.writePublisher { db in
                    try db.execute(sql: sql, arguments: arguments)
                }
            }
            .first()
            .eraseToAnyPublisher()
    }

}
