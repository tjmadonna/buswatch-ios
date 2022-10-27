//
//  Database.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import GRDB

protocol DatabaseConformable {
    var queue: DatabaseQueue { get }
}

final class Database: DatabaseConformable {

    // MARK: - Error
    enum Error: Swift.Error {
        case packagedDatabaseNotFound
    }

    // MARK: - Properties
    private static let databaseVersion = "6"

    let queue: DatabaseQueue

    // MARK: - Initialization
    init(inMemory: Bool = false) throws {
        let queue: DatabaseQueue
        if inMemory {
            // Load database queue in memory
            queue = try DatabaseQueue()
        } else {
            // Load database from file
            let fileManager = FileManager.default
            let dbUrl = try fileManager
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingDirectoryPathComponent("Data", create: true)
                .appendingPathComponent("buswatch.sqlite")

            if !fileManager.fileExists(atPath: dbUrl.path) {
                // Database doesn't exist. Copy packaged database
                guard let packagedDbUrl = Bundle.main.url(forResource: "buswatch", withExtension: "sqlite") else {
                    throw Error.packagedDatabaseNotFound
                }
                try fileManager.copyItem(at: packagedDbUrl, to: dbUrl)
            }
            queue = try DatabaseQueue(path: dbUrl.path)
        }

        // Migrate
        var migrator = DatabaseMigrator()
        migrator.registerMigration("1", migrate: DatabaseMigration.migrateToVersion1)
        migrator.registerMigration("2", migrate: DatabaseMigration.migrateToVersion2)
        migrator.registerMigration("3", migrate: DatabaseMigration.migrateToVersion3)
        migrator.registerMigration("4", migrate: DatabaseMigration.migrateToVersion4)
        migrator.registerMigration("5", migrate: DatabaseMigration.migrateToVersion5)
        migrator.registerMigration("6", migrate: DatabaseMigration.migrateToVersion6)
        try migrator.migrate(queue, upTo: Database.databaseVersion)

        // Update
        guard let packagedDbUrl = Bundle.main.url(forResource: "buswatch", withExtension: "sqlite") else {
            throw Error.packagedDatabaseNotFound
        }
        try DatabaseUpdater.updateFromPrepackagedDbURL(packagedDbUrl, queue: queue)

        self.queue = queue
    }

}
