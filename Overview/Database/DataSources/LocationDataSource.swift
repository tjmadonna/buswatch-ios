//
//  LocationDataSource.swift
//  Overview
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB
import Database

public final class LocationDataSource: LocationDataSourceRepresentable {

    private enum Error: Swift.Error {
        case locationBoundsNotFound
    }

    private let database: DatabaseDataSourceRepresentable

    private let mapper: LocationBoundsMapper

    public init(database: DatabaseDataSourceRepresentable, mapper: LocationBoundsMapper = LocationBoundsMapper()) {
        self.database = database
        self.mapper = mapper
    }

    // MARK: - LocationDataSourceRepresentable

    public func getLastLocationBounds() -> AnyPublisher<LocationBounds, Swift.Error> {
        let sql = "SELECT * FROM \(LastLocationTable.tableName)"
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql)
                    guard let lastLocation = self.mapper.mapDatabaseRowToDomainLocationBounds(row) else {
                        throw LocationDataSource.Error.locationBoundsNotFound
                    }
                    return lastLocation
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }
}
