//
//  DatabaseConstants.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import GRDB

enum StopsTable {

    static let TableName = "stops"

    static let IDColumn = "id"
    static let TitleColumn = "title"
    static let LatitudeColumn = "latitude"
    static let LongitudeColumn = "longitude"
    static let RoutesColumn = "routes"

    static let AllColumns = """
    \(IDColumn), \(TitleColumn), \(LatitudeColumn), \(LongitudeColumn), \(RoutesColumn)
    """

    enum Migration {

        static let CreateTableForVersion1 = """
        CREATE TABLE \(TableName) (
        \(IDColumn) TEXT PRIMARY KEY,
        \(TitleColumn) TEXT NOT NULL,
        \(LatitudeColumn) DOUBLE NOT NULL,
        \(LongitudeColumn) DOUBLE NOT NULL,
        \(RoutesColumn) TEXT
        )
        """
    }
}

enum FavoriteStopsTable {

    static let TableName = "favorite_stops"

    static let StopIdColumn = "stop_id"

    enum Migration {

        static let CreateTableForVersion1 = """
        CREATE TABLE \(TableName) (
        \(StopIdColumn) TEXT PRIMARY KEY,
        FOREIGN KEY (\(StopIdColumn)) REFERENCES \(StopsTable.TableName) (\(StopsTable.IDColumn))
        ON UPDATE CASCADE
        ON DELETE CASCADE
        )
        """
    }
}

enum LastLocationTable {

    static let TableName = "last_location"

    static let IDColumn = "id"
    static let NorthBoundColumn = "north"
    static let SouthBoundColumn = "south"
    static let WestBoundColumn = "west"
    static let EastBoundColumn = "east"

    static let AllColumns = """
    \(IDColumn), \(NorthBoundColumn), \(SouthBoundColumn), \(WestBoundColumn), \(EastBoundColumn)
    """

    enum Migration {

        static let CreateTableForVersion1 = """
        CREATE TABLE \(TableName) (
        \(IDColumn) INTEGER PRIMARY KEY,
        \(NorthBoundColumn) DOUBLE NOT NULL,
        \(SouthBoundColumn) DOUBLE NOT NULL,
        \(WestBoundColumn) DOUBLE NOT NULL,
        \(EastBoundColumn) DOUBLE NOT NULL
        )
        """
    }
}
