//
//  RouteLocalDataStore.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Combine
import GRDB
 
final class RouteLocalDataStore {

    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func getRoutesWithIds(_ ids: [String]) throws -> [Route] {
        return try dbQueue.read { db in
            let idSet = Set(ids)
            let placeHolderString = Array(repeating: "?", count: idSet.count).joined(separator: ", ")
            let sql = """
            SELECT * FROM \(RoutesTable.TableName) WHERE \(RoutesTable.IDColumn) IN (\(placeHolderString))
            """
            let arguments = StatementArguments(Array(idSet))
            let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
            return RoutesTableMapper.mapCursorToRoute(cursor)
        }
    }

    private func valueObservationPublisherForSQL(_ sql: String, arguments: StatementArguments) -> AnyPublisher<[Route], Error> {
        return ValueObservation.tracking { db in
            let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
            return RoutesTableMapper.mapCursorToRoute(cursor)
        }
        .publisher(in: dbQueue)
        .eraseToAnyPublisher()
    }
}
