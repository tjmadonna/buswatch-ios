//
//  ExcludedRoutesTable.swift
//  Database
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

public enum ExcludedRoutesTable {

    public static let tableName = "excluded_routes"

    public static let stopIdColumn = "stop_id"
    public static let routesColumn = "routes"

    public static let routesDelimiter = StopsTable.routesDelimiter

    public static let allColumns = """
    \(stopIdColumn), \(routesColumn)
    """

    public enum Migration {

        static let createTableForVersion3 = """
        CREATE TABLE \(tableName) (
        \(stopIdColumn) TEXT PRIMARY KEY,
        \(routesColumn) TEXT NOT NULL,
        FOREIGN KEY (\(stopIdColumn)) REFERENCES \(StopsTable.tableName) (\(StopsTable.idColumn))
        ON UPDATE CASCADE
        ON DELETE CASCADE
        )
        """
    }
}
