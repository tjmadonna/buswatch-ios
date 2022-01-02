//
//  RouteDataSource.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB
import BWTDatabase

public final class RouteDataSource: RouteDataSourceRepresentable {

    private let database: DatabaseDataSourceRepresentable

    private let dataRouteMapper: DataRouteMapper

    private let excludedRouteMapper: ExcludedRouteMapper

    public init(database: DatabaseDataSourceRepresentable,
                dataRouteMapper: DataRouteMapper = DataRouteMapper(),
                excludedRouteMapper: ExcludedRouteMapper = ExcludedRouteMapper()) {
        self.database = database
        self.dataRouteMapper = dataRouteMapper
        self.excludedRouteMapper = excludedRouteMapper
    }

    // MARK: - RouteDataSourceRepresentable

    public func getRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[DataRoute], Error> {
        let idSet = Set(routeIds)
        let placeHolderString = Array(repeating: "?", count: idSet.count).joined(separator: ", ")
        let sql = """
        SELECT r.\(RoutesTable.idColumn), r.\(RoutesTable.titleColumn), r.\(RoutesTable.colorColumn)
        FROM \(RoutesTable.tableName) AS r
        WHERE \(RoutesTable.idColumn) IN (\(placeHolderString))
        """
        let arguments = StatementArguments(Array(idSet))
        return database.queue
            .tryMap { dbQueue in
                return try dbQueue.read { db in
                    let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
                    return self.dataRouteMapper.mapDatabaseCursorToDataRouteArray(cursor)
                }
            }
            .eraseToAnyPublisher()
    }

    public func getExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Error> {
        let sql = """
        SELECT \(ExcludedRoutesTable.routesColumn) FROM \(ExcludedRoutesTable.tableName)
        WHERE \(ExcludedRoutesTable.stopIdColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
                    return self.excludedRouteMapper.mapDatabaseRowToRouteIdArray(row)
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }
}
