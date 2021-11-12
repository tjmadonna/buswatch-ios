//
//  LastLocationTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

public enum LastLocationTable {

    public static let tableName = "last_location"

    public static let idColumn = "id"
    public static let northBoundColumn = "north"
    public static let southBoundColumn = "south"
    public static let westBoundColumn = "west"
    public static let eastBoundColumn = "east"

    public static let allColumns = """
    \(idColumn), \(northBoundColumn), \(southBoundColumn), \(westBoundColumn), \(eastBoundColumn)
    """

    public enum Migration {

        static let createTableForVersion1 = """
        CREATE TABLE \(tableName) (
        \(idColumn) INTEGER PRIMARY KEY,
        \(northBoundColumn) DOUBLE NOT NULL,
        \(southBoundColumn) DOUBLE NOT NULL,
        \(westBoundColumn) DOUBLE NOT NULL,
        \(eastBoundColumn) DOUBLE NOT NULL
        )
        """
    }

    enum DefaultLocation {
        
        static var arguments: StatementArguments {
            return StatementArguments([
                LastLocationTable.idColumn: 1,
                LastLocationTable.northBoundColumn: 40.44785576556447,
                LastLocationTable.southBoundColumn: 40.4281598420304,
                LastLocationTable.westBoundColumn: -80.00565690773512,
                LastLocationTable.eastBoundColumn: -79.98956365216942
            ])
        }
    }
}
