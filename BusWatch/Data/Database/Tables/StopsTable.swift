//
//  StopsTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

enum StopsTable {

    static let tableName = "stops"

    static let idColumn = "id"
    static let titleColumn = "title"
    static let favoriteColumn = "favorite"
    static let latitudeColumn = "latitude"
    static let longitudeColumn = "longitude"
    static let routesColumn = "routes"
    static let excludedRoutesColumn = "excluded_routes"

    static let routesDelimiter = ","

    static let allColumns = """
    \(idColumn), \(titleColumn), \(favoriteColumn), \(latitudeColumn), \(longitudeColumn),
    \(routesColumn), \(excludedRoutesColumn)
    """

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
    }
}
