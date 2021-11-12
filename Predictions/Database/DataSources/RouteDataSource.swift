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
import Database

public final class RouteDataSource: RouteDataSourceRepresentable {

    private let database: DatabaseDataSourceRepresentable

    private let mapper: DataRouteMapper

    public init(database: DatabaseDataSourceRepresentable, mapper: DataRouteMapper = DataRouteMapper()) {
        self.database = database
        self.mapper = mapper
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
                    return self.mapper.mapDatabaseCursorToDataRouteArray(cursor)
                }
            }
            .eraseToAnyPublisher()
    }
}
