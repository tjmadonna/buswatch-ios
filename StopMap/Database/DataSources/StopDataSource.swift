//
//  StopsDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB
import Database

public final class StopDataSource: StopDataSourceRepresentable {

    private let database: DatabaseDataSourceRepresentable

    private let mapper: StopMapper

    public init(database: DatabaseDataSourceRepresentable, mapper: StopMapper = StopMapper()) {
        self.database = database
        self.mapper = mapper
    }

    public func getStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[Stop], Error> {
        let sql = """
        SELECT *
        FROM \(StopsTable.tableName)
        WHERE \(StopsTable.latitudeColumn) <= ?
        AND \(StopsTable.latitudeColumn) >= ?
        AND \(StopsTable.longitudeColumn) >= ?
        AND \(StopsTable.longitudeColumn) <= ?
        """
        let arguments = StatementArguments([locationBounds.north, locationBounds.south, locationBounds.west, locationBounds.east])
        return valueObservationPublisherForSQL(sql, arguments: arguments)
    }

    private func valueObservationPublisherForSQL(_ sql: String, arguments: StatementArguments) -> AnyPublisher<[Stop], Error> {
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
