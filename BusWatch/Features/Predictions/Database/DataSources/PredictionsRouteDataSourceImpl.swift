//
//  PredictionsRouteDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class PredictionsRouteDataSourceImpl: PredictionsRouteDataSource {

    private let database: DatabaseDataSource

    private let dataRouteMapper: PredictionsDataRouteMapper

    private let excludedRouteMapper: PredictionsExcludedRouteMapper

    init(database: DatabaseDataSource,
         dataRouteMapper: PredictionsDataRouteMapper = PredictionsDataRouteMapper(),
         excludedRouteMapper: PredictionsExcludedRouteMapper = PredictionsExcludedRouteMapper()) {
        self.database = database
        self.dataRouteMapper = dataRouteMapper
        self.excludedRouteMapper = excludedRouteMapper
    }

    // MARK: - PredictionsRouteDataSource

    func getRoutesWithIds(_ routeIds: [String]) -> AnyPublisher<[PredictionsDataRoute], Error> {
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

    func getExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Error> {
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
