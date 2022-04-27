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

final class DatabaseImpl: Database {

    // MARK: - Properties

    private static let databaseVersion = "5"

    private let queueSubject = CurrentValueSubject<DatabaseQueue?, Error>(nil)

    // MARK: - Initialization

    init(databasePath: URL, fileManager: FileManager = .default, bundle: Bundle = .main) {
        do {
            if !fileManager.fileExists(atPath: databasePath.path) {
                guard let packagedDbUrl = bundle.url(forResource: "buswatch", withExtension: "sqlite") else {
                    fatalError("Prepackaged database not found")
                }
                try fileManager.copyItem(at: packagedDbUrl, to: databasePath)
            }

            let queue = try DatabaseQueue(path: databasePath.path)
            queueSubject.value = queue
            try self.migrator.migrate(queue, upTo: DatabaseImpl.databaseVersion)
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

        migrator.registerMigration("4") { db in
            try StopsTable.Migration.alterTableForVersion4.forEach { sql in
                try db.execute(sql: sql)
            }
            try db.execute(sql: FavoriteStopsTable.Migration.dropTableForVersion4)
            try db.execute(sql: ExcludedRoutesTable.Migration.dropTableForVersion4)
        }

        migrator.registerMigration("5") { db in
            try StopsTable.Migration.alterTableForVersion5(db: db)
        }

        return migrator
    }()

    // MARK: - DatabaseDataSource

    var queue: AnyPublisher<DatabaseQueue, Error> {
        queueSubject.compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
