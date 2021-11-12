//
//  RoutesTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//b

import Foundation

public enum RoutesTable {

    public static let tableName = "routes"

    public static let idColumn = "id"
    public static let titleColumn = "title"
    public static let colorColumn = "color"

    public static let allColumns = """
    \(idColumn), \(titleColumn), \(colorColumn)
    """

    public enum Migration {

        static let createTableForVersion2 = """
        CREATE TABLE \(tableName) (
        \(idColumn) TEXT PRIMARY KEY,
        \(titleColumn) TEXT NOT NULL,
        \(colorColumn) TEXT NOT NULL
        )
        """
    }
}
