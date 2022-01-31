//
//  OverviewLocationDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class OverviewLocationDataSourceImpl: OverviewLocationDataSource {

    private enum Error: Swift.Error {
        case locationBoundsNotFound
    }

    private let database: DatabaseDataSource

    private let mapper: OverviewLocationBoundsMapper

    init(database: DatabaseDataSource,
         mapper: OverviewLocationBoundsMapper = OverviewLocationBoundsMapper()) {
        self.database = database
        self.mapper = mapper
    }

    // MARK: - OverviewLocationDataSource

    func getLastLocationBounds() -> AnyPublisher<OverviewLocationBounds, Swift.Error> {
        let sql = "SELECT * FROM \(LastLocationTable.tableName)"
        return database.queue
            .flatMap { dbQueue in
                return ValueObservation.tracking { db in
                    let row = try Row.fetchOne(db, sql: sql)
                    guard let lastLocation = self.mapper.mapDatabaseRowToDomainLocationBounds(row) else {
                        throw OverviewLocationDataSourceImpl.Error.locationBoundsNotFound
                    }
                    return lastLocation
                }
                .publisher(in: dbQueue)
            }
            .eraseToAnyPublisher()
    }
}
