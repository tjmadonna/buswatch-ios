//
//  DatabaseDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 1/30/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class DatabaseDataSourceImpl: DatabaseDataSource {

    // MARK: - Properties

    private static let databaseVersion = "3"

    private let queueSubject = CurrentValueSubject<DatabaseQueue?, Error>(nil)

    // MARK: - Initialization

    init(databasePath: URL, databasePopulator: DatabasePopulator) {
        do {
            let queue = try DatabaseQueue(path: databasePath.absoluteString)
            queueSubject.value = queue
            try self.migrator.migrate(queue, upTo: DatabaseDataSourceImpl.databaseVersion)
            try self.attemptToPopulateDatabase(queue, databasePopulator: databasePopulator)
        } catch {
            queueSubject.send(completion: .failure(error))
        }
    }

    // MARK: - Migration

    private let migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("1") { db in
            try db.execute(sql: StopsTable.Migration.createTableForVersion1)
            try db.execute(sql: FavoriteStopsTable.Migration.createTableForVersion1)
            try db.execute(sql: LastLocationTable.Migration.createTableForVersion1)
        }

        migrator.registerMigration("2") {db in
            try db.execute(sql: RoutesTable.Migration.createTableForVersion2)
        }

        migrator.registerMigration("3") { db in
            try db.execute(sql: ExcludedRoutesTable.Migration.createTableForVersion3)
        }

        return migrator
    }()

    // MARK: - Populator

    private func attemptToPopulateDatabase(_ queue: DatabaseQueue, databasePopulator: DatabasePopulator) throws {
        try queue.inDatabase { db in
            if databasePopulator.needsPopulated(db) {
                try databasePopulator.populateDatabase(db)
            }
        }
    }

    // MARK: - DatabaseDataSource

    var queue: AnyPublisher<DatabaseQueue, Error> {
        queueSubject.compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
