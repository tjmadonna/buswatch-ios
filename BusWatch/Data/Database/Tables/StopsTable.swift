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
    static let latitudeColumn = "latitude"
    static let longitudeColumn = "longitude"
    static let routesColumn = "routes"

    static let routesDelimiter = ","

    static let allColumns = """
    \(idColumn), \(titleColumn), \(latitudeColumn), \(longitudeColumn), \(routesColumn)
    """

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
    }
}
