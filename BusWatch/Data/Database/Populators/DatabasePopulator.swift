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

    private static let stopVersion = 2

    private static let routeVersion = 1

    private static let stopFileUrl = Bundle.main.url(forResource: "stops", withExtension: "json")!

    private static let routeFileUrl = Bundle.main.url(forResource: "routes", withExtension: "json")!

    private var userDefaultaDataSource: UserDefaultsDataSource

    private let stopMapper: DatabaseStopMapper

    private let routeMapper: DatabaseRouteMapper

    init(userDefaultaDataSource: UserDefaultsDataSource,
         stopMapper: DatabaseStopMapper = DatabaseStopMapper(),
         routeMapper: DatabaseRouteMapper = DatabaseRouteMapper()) {
        self.userDefaultaDataSource = userDefaultaDataSource
        self.stopMapper = stopMapper
        self.routeMapper = routeMapper
    }

    func needsPopulated(_ db: Database) -> Bool {
        let id = try? String.fetchOne(db,
                                      sql: "SELECT \(LastLocationTable.idColumn) FROM \(LastLocationTable.tableName)")
        return id == nil ||
            userDefaultaDataSource.stopVersion < DatabasePopulator.stopVersion ||
            userDefaultaDataSource.routeVersion < DatabasePopulator.routeVersion
    }

    func populateDatabase(_ db: Database) throws {

        try db.inTransaction { () -> Database.TransactionCompletion in

            if userDefaultaDataSource.stopVersion < DatabasePopulator.stopVersion {
                try updateStops(db)
            }

            if userDefaultaDataSource.routeVersion < DatabasePopulator.routeVersion {
                try updateRoutes(db)
            }

            let sql = "SELECT \(LastLocationTable.idColumn) FROM \(LastLocationTable.tableName)"
            if try String.fetchOne(db, sql: sql) == nil {
                try updatedLastLocation(db)
            }

            userDefaultaDataSource.stopVersion = DatabasePopulator.stopVersion
            userDefaultaDataSource.routeVersion = DatabasePopulator.routeVersion

            return .commit
        }
    }

    private func updateStops(_ db: Database) throws {
        let newStopData = try Data(contentsOf: DatabasePopulator.stopFileUrl)
        let newStopDecodables = try JSONDecoder().decode([DecodableStop].self, from: newStopData)
        let newStops = self.stopMapper.mapDecodableStopArrayToDatabaseStopArray(newStopDecodables)

        let cursor = try Row.fetchCursor(db, sql: "SELECT * FROM \(StopsTable.tableName)")
        let oldStops = self.stopMapper.mapDatabaseCursorToDatabaseStopArray(cursor)

        let stagedChangeset = StagedChangeset(source: oldStops, target: newStops)

        let updateSql = """
        UPDATE \(StopsTable.tableName)
        SET \(StopsTable.titleColumn) = :\(StopsTable.titleColumn),
        \(StopsTable.latitudeColumn) = :\(StopsTable.latitudeColumn),
        \(StopsTable.longitudeColumn) = :\(StopsTable.longitudeColumn),
        \(StopsTable.routesColumn) = :\(StopsTable.routesColumn)
        WHERE \(StopsTable.idColumn) = :\(StopsTable.idColumn)
        """

        let insertSql = """
        INSERT INTO \(StopsTable.tableName) (\(StopsTable.allColumns))
        VALUES (
        :\(StopsTable.idColumn),
        :\(StopsTable.titleColumn),
        :\(StopsTable.latitudeColumn),
        :\(StopsTable.longitudeColumn),
        :\(StopsTable.routesColumn))
        """

        let deleteSql = """
        DELETE FROM \(StopsTable.tableName) WHERE \(StopsTable.idColumn) = ?
        """

        for changeset in stagedChangeset {
            for updated in changeset.elementUpdated {
                let updatedStop = newStops[updated.element]
                try db.execute(sql: updateSql,
                               arguments: self.stopMapper.mapDatabaseStopToStatementArguments(updatedStop))
            }

            for inserted in changeset.elementInserted {
                let insertedStop = newStops[inserted.element]
                try db.execute(sql: insertSql, arguments: stopMapper.mapDatabaseStopToStatementArguments(insertedStop))
            }

            for deleted in changeset.elementDeleted {
                let deletedStop = oldStops[deleted.element]
                try db.execute(sql: deleteSql, arguments: [deletedStop.id])
            }
        }
    }

    private func updateRoutes(_ db: Database) throws {
        let newRouteData = try Data(contentsOf: DatabasePopulator.routeFileUrl)
        let newRouteDecodables = try JSONDecoder().decode([DecodableRoute].self, from: newRouteData)
        let newRoutes = self.routeMapper.mapDecodableRouteArrayToDatabaseRouteArray(newRouteDecodables)

        // Delete entries in table
        try db.execute(sql: "DELETE FROM \(RoutesTable.tableName)")

        let insertSql = """
        INSERT INTO \(RoutesTable.tableName) (\(RoutesTable.allColumns))
        VALUES (
        :\(RoutesTable.idColumn),
        :\(RoutesTable.titleColumn),
        :\(RoutesTable.colorColumn)
        )
        """
        for route in newRoutes {
            try db.execute(sql: insertSql, arguments: routeMapper.mapDatabaseRouteToStatementArguments(route))
        }
    }

    private func updatedLastLocation(_ db: Database) throws {
        // Insert default location
        let locationSql = """
        INSERT INTO \(LastLocationTable.tableName) (\(LastLocationTable.allColumns))
        VALUES (
        :\(LastLocationTable.idColumn),
        :\(LastLocationTable.northBoundColumn),
        :\(LastLocationTable.southBoundColumn),
        :\(LastLocationTable.westBoundColumn),
        :\(LastLocationTable.eastBoundColumn)
        )
        """
        try db.execute(sql: locationSql, arguments: LastLocationTable.DefaultLocation.arguments)
    }
}
