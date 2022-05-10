//
//  StopsTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

enum StopsTable {

    static let tableName = "stops"

    static let idColumn = "id"
    static let titleColumn = "title"
    static let latitudeColumn = "latitude"
    static let longitudeColumn = "longitude"
    static let routesColumn = "routes"
    static let serviceTypeColumn = "service_type"

    static let routesDelimiter = ","
    static let busServiceType = 0
    static let lightRailServiceType = 1

    // Legacy
    static let favoriteColumn = "favorite"
    static let excludedRoutesColumn = "excluded_routes"

    enum Migration {

        static let createTableForVersion1 = """
        CREATE TABLE \(tableName) (
        \(idColumn) TEXT PRIMARY KEY,
        \(titleColumn) TEXT NOT NULL,
        \(latitudeColumn) DOUBLE NOT NULL,
        \(longitudeColumn) DOUBLE NOT NULL,
        \(routesColumn) TEXT
        )
        """

        static let alterTableForVersion4 = [
        """
        ALTER TABLE \(tableName) ADD \(favoriteColumn) INTEGER NOT NULL DEFAULT 0
        """,
        """
        ALTER TABLE \(tableName) ADD \(excludedRoutesColumn) TEXT
        """
        ]

        static func alterTablesForVersion5(db: GRDB.Database) throws {
            // Rename old table
            let renameSql = "ALTER TABLE \(tableName) RENAME TO \(tableName)_old"
            try db.execute(sql: renameSql)

            // Create new tables
            let newStopsSql = """
            CREATE TABLE \(tableName) (
            \(idColumn) TEXT PRIMARY KEY,
            \(titleColumn) TEXT NOT NULL,
            \(latitudeColumn) DOUBLE NOT NULL,
            \(longitudeColumn) DOUBLE NOT NULL,
            \(routesColumn) TEXT,
            \(serviceTypeColumn) INTEGER NOT NULL DEFAULT 0
            )
            """
            try db.execute(sql: newStopsSql)

            try FavoriteStopsTable.Migration.createTableForVersion5(db: db)
            try ExcludedRoutesTable.Migration.createTableForVersion5(db: db)

            // Copy stops to new table
            let copyStopsSql = """
            INSERT INTO \(tableName) (\(idColumn), \(titleColumn), \(latitudeColumn), \(longitudeColumn),
            \(routesColumn))
            SELECT \(idColumn), \(titleColumn), \(latitudeColumn), \(longitudeColumn),
            \(routesColumn) FROM \(tableName)_old
            """
            try db.execute(sql: copyStopsSql)

            // Update service types in stops
            let updateServiceType = """
            UPDATE \(tableName) SET \(serviceTypeColumn) = 1
            WHERE \(routesColumn) LIKE '%RED%' OR \(routesColumn) LIKE '%BLUE%' OR \(routesColumn) LIKE '%SLVR%'
            """
            try db.execute(sql: updateServiceType)

            // Copy favorite stops to new table
            let copyFavoriteStopsSql = """
            INSERT INTO \(FavoriteStopsTable.tableName) (\(FavoriteStopsTable.stopIdColumn))
            SELECT \(idColumn) FROM \(tableName)_old
            WHERE \(favoriteColumn) = 1
            """
            try db.execute(sql: copyFavoriteStopsSql)

            // Copy excluded routes to new table
            let copyExcludedRoutesSql = """
            INSERT INTO \(ExcludedRoutesTable.tableName) (\(ExcludedRoutesTable.allColumns))
            SELECT \(idColumn), \(excludedRoutesColumn) FROM \(tableName)_old
            WHERE \(excludedRoutesColumn) NOT NULL
            """
            try db.execute(sql: copyExcludedRoutesSql)

            // Drop old table
            try db.execute(sql: "DROP TABLE \(tableName)_old")
        }
    }
}
