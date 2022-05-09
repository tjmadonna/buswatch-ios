//
//  FavoriteStopsTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

enum FavoriteStopsTable {

    static let tableName = "favorite_stops"

    static let stopIdColumn = "stop_id"

    enum Migration {

        static let createTableForVersion1 = """
        CREATE TABLE \(tableName) (
        \(stopIdColumn) TEXT PRIMARY KEY,
        FOREIGN KEY (\(stopIdColumn)) REFERENCES \(StopsTable.tableName) (\(StopsTable.idColumn))
        ON UPDATE CASCADE
        ON DELETE CASCADE
        )
        """

        static let dropTableForVersion4 = """
        DROP TABLE IF EXISTS \(tableName)
        """

        static func createTableForVersion5(db: GRDB.Database) throws {
            try db.execute(sql: createTableForVersion1)
        }
    }
}
