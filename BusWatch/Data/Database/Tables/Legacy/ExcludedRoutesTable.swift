//
//  ExcludedRoutesTable.swift
//  Database
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

enum ExcludedRoutesTable {

    static let tableName = "excluded_routes"

    static let stopIdColumn = "stop_id"
    static let routesColumn = "routes"

    static let routesDelimiter = StopsTable.routesDelimiter

    static let allColumns = """
    \(stopIdColumn), \(routesColumn)
    """

    enum Migration {

        static let createTableForVersion3 = """
        CREATE TABLE \(tableName) (
        \(stopIdColumn) TEXT PRIMARY KEY,
        \(routesColumn) TEXT NOT NULL,
        FOREIGN KEY (\(stopIdColumn)) REFERENCES \(StopsTable.tableName) (\(StopsTable.idColumn))
        ON UPDATE CASCADE
        ON DELETE CASCADE
        )
        """

        static let dropTableForVersion4 = """
        DROP TABLE IF EXISTS \(tableName)
        """
    }
}
