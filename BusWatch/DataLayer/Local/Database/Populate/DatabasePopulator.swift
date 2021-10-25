//
//  DatabasePopulator.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB
import DifferenceKit

final class DatabasePopulator {

    private static let stopVersion = 1

    private static let stopFileUrl = Bundle.main.url(forResource: "stops", withExtension: "json")!

    private let userDefaultStore: UserDefaultStore

    init(userDefaultStore: UserDefaultStore) {
        self.userDefaultStore = userDefaultStore
    }

    func needsPopulated(_ db: Database) -> Bool {
        let id = try? String.fetchOne(db, sql: "SELECT \(LastLocationTable.IDColumn) FROM \(LastLocationTable.TableName)")
        return id == nil || userDefaultStore.stopVersion < DatabasePopulator.stopVersion
    }

    func populateDatabase(_ db: Database) throws {

        try db.inTransaction { () -> Database.TransactionCompletion in

            if userDefaultStore.stopVersion < DatabasePopulator.stopVersion {
                try updateStops(db)
            }

            if try String.fetchOne(db, sql: "SELECT \(LastLocationTable.IDColumn) FROM \(LastLocationTable.TableName)") == nil {
                try updatedLastLocation(db)
            }

            userDefaultStore.stopVersion = DatabasePopulator.stopVersion

            return .commit
        }
    }

    private func updateStops(_ db: Database) throws {
        let newStopData = try Data(contentsOf: DatabasePopulator.stopFileUrl)
        let newStopDecodables = try JSONDecoder().decode([StopDecodable].self, from: newStopData)
        let newStops = newStopDecodables.compactMap{ $0.mapToStop() }

        let cursor = try Row.fetchCursor(db, sql: "SELECT * FROM \(StopsTable.TableName)")
        let oldStops = StopsTableMapper.mapCursorToStopList(cursor)

        let stagedChangeset = StagedChangeset(source: oldStops, target: newStops)

        let updateSql = """
        UPDATE \(StopsTable.TableName)
        SET \(StopsTable.TitleColumn) = :\(StopsTable.TitleColumn),
        \(StopsTable.LatitudeColumn) = :\(StopsTable.LatitudeColumn),
        \(StopsTable.LongitudeColumn) = :\(StopsTable.LongitudeColumn),
        \(StopsTable.RoutesColumn) = :\(StopsTable.RoutesColumn)
        WHERE \(StopsTable.IDColumn) = :\(StopsTable.IDColumn)
        """

        let insertSql = """
        INSERT INTO \(StopsTable.TableName) (\(StopsTable.AllColumns))
        VALUES (
        :\(StopsTable.IDColumn),
        :\(StopsTable.TitleColumn),
        :\(StopsTable.LatitudeColumn),
        :\(StopsTable.LongitudeColumn),
        :\(StopsTable.RoutesColumn))
        """

        let deleteSql = """
        DELETE FROM \(StopsTable.TableName) WHERE \(StopsTable.IDColumn) = ?
        """

        for changeset in stagedChangeset {
            for updated in changeset.elementUpdated {
                let updatedStop = oldStops[updated.element]
                try db.execute(sql: updateSql, arguments: StopsTableMapper.mapStopToArguments(updatedStop))
            }

            for inserted in changeset.elementInserted {
                let updatedStop = newStops[inserted.element]
                try db.execute(sql: insertSql, arguments: StopsTableMapper.mapStopToArguments(updatedStop))
            }

            for deleted in changeset.elementDeleted {
                let deletedStop = oldStops[deleted.element]
                try db.execute(sql: deleteSql, arguments: [deletedStop.id])
            }
        }
    }

    private func updatedLastLocation(_ db: Database) throws {
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
    }
}
