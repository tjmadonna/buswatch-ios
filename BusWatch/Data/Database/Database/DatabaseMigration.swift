//
//  DatabaseMigration.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

enum DatabaseMigration {

    static func migrateToVersion1(db: GRDB.Database) throws {
        try db.execute(sql: StopsTable.Migration.createTableForVersion1)
        try db.execute(sql: FavoriteStopsTable.Migration.createTableForVersion1)
        try db.execute(sql: LastLocationTable.Migration.createTableForVersion1)
    }

    static func migrateToVersion2(db: GRDB.Database) throws {
        try db.execute(sql: RoutesTable.Migration.createTableForVersion2)
    }

    static func migrateToVersion3(db: GRDB.Database) throws {
        try db.execute(sql: ExcludedRoutesTable.Migration.createTableForVersion3)
    }

    static func migrateToVersion4(db: GRDB.Database) throws {
        try StopsTable.Migration.alterTableForVersion4.forEach { sql in
            try db.execute(sql: sql)
        }
        try db.execute(sql: FavoriteStopsTable.Migration.dropTableForVersion4)
        try db.execute(sql: ExcludedRoutesTable.Migration.dropTableForVersion4)
    }

    static func migrateToVersion5(db: GRDB.Database) throws {
        try StopsTable.Migration.alterTableForVersion5(db: db)
        try ResourceVersionsTable.Migration.createTableForVersion5(db: db)
    }
}
