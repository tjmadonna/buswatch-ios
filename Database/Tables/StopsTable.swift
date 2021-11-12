//
//  StopsTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

public enum StopsTable {

    public static let tableName = "stops"

    public static let idColumn = "id"
    public static let titleColumn = "title"
    public static let latitudeColumn = "latitude"
    public static let longitudeColumn = "longitude"
    public static let routesColumn = "routes"

    public static let routesDelimiter = ","

    public static let allColumns = """
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
