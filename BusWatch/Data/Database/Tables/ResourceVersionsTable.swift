//
//  ResourceVersionsTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

enum ResourceVersionsTable {

    static let tableName = "resource_versions"

    static let versionColumn = "version"

    enum Migration {

        static func createTableForVersion5(db: GRDB.Database) throws {
            let sql = """
            CREATE TABLE \(tableName) (
            \(versionColumn) INTEGER PRIMARY KEY
            )
            """
            try db.execute(sql: sql)
        }
    }
}
