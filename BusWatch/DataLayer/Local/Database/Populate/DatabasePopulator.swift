//
//  DatabasePopulator.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import GRDB

final class DatabasePopulator {

    private static let StopFileUrl = Bundle.main.url(forResource: "stops", withExtension: "json")!

    func populateDatabase(_ db: Database) throws {
        let stopData = try Data(contentsOf: DatabasePopulator.StopFileUrl)
        let stopDecodables = try JSONDecoder().decode([StopDecodable].self, from: stopData)

        try db.inTransaction { () -> Database.TransactionCompletion in
            // Insert stops
            let sql = """
            INSERT INTO \(StopsTable.TableName) (\(StopsTable.AllColumns))
            VALUES (
            :\(StopsTable.IDColumn),
            :\(StopsTable.TitleColumn),
            :\(StopsTable.LatitudeColumn),
            :\(StopsTable.LongitudeColumn),
            :\(StopsTable.RoutesColumn)
            )
            """
            try stopDecodables.forEach { stop in
                if let args = stop.arguments {
                    try db.execute(sql: sql, arguments: args)
                }
            }

            // Insert default location
            let locationSql = """
            INSERT INTO \(LastLocationTable.TableName) (\(LastLocationTable.AllColumns))
            VALUES (
            :\(LastLocationTable.IDColumn),
            :\(LastLocationTable.NorthBoundColumn),
            :\(LastLocationTable.SouthBoundColumn),
            :\(LastLocationTable.WestBoundColumn),
            :\(LastLocationTable.EastBoundColumn)
            )
            """
            try db.execute(sql: locationSql, arguments: DefaultLocationBounds.arguments)

            return .commit
        }
    }
}
