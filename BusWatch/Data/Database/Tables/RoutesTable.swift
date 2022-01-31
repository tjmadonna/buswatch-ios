//
//  RoutesTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

enum RoutesTable {

    static let tableName = "routes"

    static let idColumn = "id"
    static let titleColumn = "title"
    static let colorColumn = "color"

    static let allColumns = """
    \(idColumn), \(titleColumn), \(colorColumn)
    """

    enum Migration {

        static let createTableForVersion2 = """
        CREATE TABLE \(tableName) (
        \(idColumn) TEXT PRIMARY KEY,
        \(titleColumn) TEXT NOT NULL,
        \(colorColumn) TEXT NOT NULL
        )
        """
    }
}
