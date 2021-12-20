//
//  StopDataSource.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB
import BWTDatabase

public final class StopDataSource: StopDataSourceRepresentable {

    private enum Error: Swift.Error {
        case stopNotFound
    }

    private let database: DatabaseDataSourceRepresentable

    private let mapper: StopMapper

    public init(database: DatabaseDataSourceRepresentable, mapper: StopMapper = StopMapper()) {
        self.database = database
        self.mapper = mapper
    }

    // MARK: - StopDataSourceRepresentable

    public func getStopById(_ stopId: String) -> AnyPublisher<Stop, Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), \(FavoriteStopsTable.stopIdColumn)
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
                    guard let stop = self.mapper.mapDatabaseRowToDomainStop(row) else {
                        throw StopDataSource.Error.stopNotFound
                    }
                    return stop
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }

    public func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error> {
        let sql = "INSERT INTO \(FavoriteStopsTable.tableName) ( \(FavoriteStopsTable.stopIdColumn) ) VALUES ( ? )"
        return writePublisherForSQL(sql, arguments: [stopId])
    }

    public func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Swift.Error> {
        let sql = "DELETE FROM \(FavoriteStopsTable.tableName) WHERE \(FavoriteStopsTable.stopIdColumn) = ?"
        return writePublisherForSQL(sql, arguments: [stopId])
    }

    private func writePublisherForSQL(_ sql: String, arguments: StatementArguments) -> AnyPublisher<Void, Swift.Error> {
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
