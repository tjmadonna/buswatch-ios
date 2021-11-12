//
//  FavoriteStopDataSource.swift
//  Overview
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB
import Database

public final class FavoriteStopDataSource: FavoriteStopDataSourceRepresentable {

    private let database: DatabaseDataSourceRepresentable

    private let mapper: FavoriteStopMapper

    public init(database: DatabaseDataSourceRepresentable, mapper: FavoriteStopMapper = FavoriteStopMapper()) {
        self.database = database
        self.mapper = mapper
    }

    // MARK: - FavoriteStopDataSourceRepresentable

    public func getFavoriteStops() -> AnyPublisher<[FavoriteStop], Error> {
        let sql = """
        SELECT \(StopsTable.idColumn), \(StopsTable.titleColumn), \(StopsTable.routesColumn)
        FROM \(StopsTable.tableName)
        INNER JOIN \(FavoriteStopsTable.tableName)
        ON \(StopsTable.tableName).\(StopsTable.idColumn) = \(FavoriteStopsTable.tableName).\(FavoriteStopsTable.stopIdColumn)
        """
        return valueObservationPublisherForSQL(sql)
    }

    private func valueObservationPublisherForSQL(_ sql: String) -> AnyPublisher<[FavoriteStop], Error> {
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let cursor = try Row.fetchCursor(db, sql: sql)
                    return self.mapper.mapDatabaseCursorToDomainFavoriteStopArray(cursor)
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }
}
