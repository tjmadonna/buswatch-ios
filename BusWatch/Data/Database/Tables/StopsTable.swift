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
    static let favoriteColumn = "favorite"
    static let latitudeColumn = "latitude"
    static let longitudeColumn = "longitude"
    static let routesColumn = "routes"
    static let excludedRoutesColumn = "excluded_routes"
    static let serviceTypeColumn = "service_type"

    static let routesDelimiter = ","
    static let busServiceType = 0
    static let lightRailServiceType = 1

    enum Migration {

        static let createTableForVersion1 = """
        CREATE TABLE \(tableName) (
        \(idColumn) TEXT PRIMARY KEY,
        \(titleColumn) TEXT NOT NULL,
        \(favoriteColumn) INTEGER NOT NULL DEFAULT 0,
        \(latitudeColumn) DOUBLE NOT NULL,
        \(longitudeColumn) DOUBLE NOT NULL,
        \(routesColumn) TEXT,
        \(excludedRoutesColumn) TEXT
        )
        """

        static let alterTableForVersion4 = [
        """
        ALTER TABLE \(tableName) ADD \(favoriteColumn) INTEGER NOT NULL DEFAULT 0;
        """,
        """
        ALTER TABLE \(tableName) ADD \(excludedRoutesColumn) TEXT;
        """
        ]

        static func alterTableForVersion5(db: GRDB.Database) throws {
            let sql = "ALTER TABLE \(tableName) ADD \(serviceTypeColumn) INTEGER NOT NULL DEFAULT \(busServiceType)"
            try db.execute(sql: sql)

            let updateSql = """
            UPDATE \(tableName)
            SET \(serviceTypeColumn) = \(lightRailServiceType)
            WHERE \(routesColumn) LIKE '%RED%'
            OR \(routesColumn) LIKE '%BLUE%'
            OR \(routesColumn) LIKE '%SLVR%';
            """
            try db.execute(sql: updateSql)
        }
    }
}
