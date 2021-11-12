//
//  FavoriteStopsTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

public enum FavoriteStopsTable {

    public static let tableName = "favorite_stops"

    public static let stopIdColumn = "stop_id"

    public enum Migration {

        static let createTableForVersion1 = """
        CREATE TABLE \(tableName) (
        \(stopIdColumn) TEXT PRIMARY KEY,
        FOREIGN KEY (\(stopIdColumn)) REFERENCES \(StopsTable.tableName) (\(StopsTable.idColumn))
        ON UPDATE CASCADE
        ON DELETE CASCADE
        )
        """
    }
}
