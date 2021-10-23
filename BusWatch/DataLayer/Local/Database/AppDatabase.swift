//
//  AppDatabase.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class AppDatabase {

    // MARK: - Properties

    private static let DatabaseVersion = "1"

    let queue: DatabaseQueue

    // MARK: - Initialization

    init(databasePath: URL, populator: DatabasePopulator = DatabasePopulator()) throws {
        self.queue = try DatabaseQueue(path: databasePath.absoluteString)
        try self.migrator.migrate(queue, upTo: AppDatabase.DatabaseVersion)
        try self.attemptToPopulateDatabase(self.queue, populator: populator)
    }

    // MARK: - Populate

    private func attemptToPopulateDatabase(_ databaseQueue: DatabaseQueue, populator: DatabasePopulator) throws {
        try databaseQueue.inDatabase { db in
            // Populate database if no stops exist
            if try String.fetchOne(db, sql: "SELECT \(StopsTable.IDColumn) FROM \(StopsTable.TableName)") == nil {
                try populator.populateDatabase(db)
            }
        }
    }

    // MARK: - Migration

    private let migrator: DatabaseMigrator = {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("1") { db in
            try db.execute(sql: StopsTable.Migration.CreateTableForVersion1)
            try db.execute(sql: FavoriteStopsTable.Migration.CreateTableForVersion1)
            try db.execute(sql: LastLocationTable.Migration.CreateTableForVersion1)
        }

        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        return migrator
    }()
}
