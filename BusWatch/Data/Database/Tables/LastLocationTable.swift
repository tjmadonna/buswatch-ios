//
//  LastLocationTable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/25/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

enum LastLocationTable {

    static let tableName = "last_location"

    static let idColumn = "id"
    static let northBoundColumn = "north"
    static let southBoundColumn = "south"
    static let westBoundColumn = "west"
    static let eastBoundColumn = "east"

    static let allColumns = """
    \(idColumn), \(northBoundColumn), \(southBoundColumn), \(westBoundColumn), \(eastBoundColumn)
    """

    enum Migration {

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
