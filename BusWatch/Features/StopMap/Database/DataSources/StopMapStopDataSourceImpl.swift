//
//  StopMapStopDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class StopMapStopDataSourceImpl: StopMapStopDataSource {

    private let database: DatabaseDataSource

    private let mapper: StopMapStopMapper

    init(database: DatabaseDataSource, mapper: StopMapStopMapper = StopMapStopMapper()) {
        self.database = database
        self.mapper = mapper
    }

    // MARK: - StopMapStopDataSource

    func getStopsInLocationBounds(_ locationBounds: StopMapLocationBounds) -> AnyPublisher<[StopMapStop], Error> {
        let sql = """
        SELECT *
        FROM \(StopsTable.tableName)
        WHERE \(StopsTable.latitudeColumn) <= ?
        AND \(StopsTable.latitudeColumn) >= ?
        AND \(StopsTable.longitudeColumn) >= ?
        AND \(StopsTable.longitudeColumn) <= ?
        """
        let arguments = StatementArguments([locationBounds.north,
                                            locationBounds.south,
                                            locationBounds.west,
                                            locationBounds.east])
        return valueObservationPublisherForSQL(sql, arguments: arguments)
    }

    // MARK: - Helper functions

    private func valueObservationPublisherForSQL(_ sql: String,
                                                 arguments: StatementArguments) -> AnyPublisher<[StopMapStop], Error> {
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
                    return self.mapper.mapDatabaseCursorToDomainStopArray(cursor)
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }
}
