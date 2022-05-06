//
//  GRDBDatabaseQueueExtensions.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

extension DatabaseQueue {

    final class Builder {

        private let fileManager: FileManager

        private let databasePath: URL

        private let version: String

        private let inMemory: Bool

        private var migrator = DatabaseMigrator()

        private var createFromFileUrl: URL?

        private var migrationVersion: Int?

        private var populator: ((GRDB.DatabaseQueue) throws -> Void)?

        init(databasePath: URL, version: String, inMemory: Bool = false, fileManager: FileManager = .default) {
            self.databasePath = databasePath
            self.version = version
            self.inMemory = inMemory
            self.fileManager = fileManager
        }

        func createFromFile(_ filepath: URL) -> DatabaseQueue.Builder {
            self.createFromFileUrl = filepath
            return self
        }

        func addMigration(_ identifier: String,
                          migration: @escaping (GRDB.Database) throws -> Void) -> DatabaseQueue.Builder {
            self.migrator.registerMigration(identifier, migrate: migration)
            return self
        }

        func addPopulator(_ populator: @escaping (GRDB.DatabaseQueue) throws -> Void) -> DatabaseQueue.Builder {
            self.populator = populator
            return self
        }

        func build() throws -> DatabaseQueue {
            if let createFromFileUrl = createFromFileUrl, !fileManager.fileExists(atPath: databasePath.path) {
                // Copy database file
                try fileManager.copyItem(at: createFromFileUrl, to: databasePath)
            }

            let queue = try DatabaseQueue(path: databasePath.path)
            try migrator.migrate(queue, upTo: version)

            if let populator = populator {
                try populator(queue)
            }

            return queue
        }
    }
}
