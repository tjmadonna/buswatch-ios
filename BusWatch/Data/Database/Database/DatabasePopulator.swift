//
//  DatabasePopulator.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import DifferenceKit
import Foundation
import GRDB

enum DatabasePopulator {

    fileprivate struct PopulatorStop: Codable, FetchableRecord, PersistableRecord, Differentiable {
        let id: String
        let title: String
        let latitude: Double
        let longitude: Double
        let routes: String
        let serviceType: Int

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case latitude
            case longitude
            case routes
            case serviceType = "service_type"
        }

        var differenceIdentifier: String {
            return id
        }

        func isContentEqual(to source: DatabasePopulator.PopulatorStop) -> Bool {
            return self.id == source.id &&
                self.title == source.title &&
                self.latitude == source.latitude &&
                self.longitude == source.longitude &&
                self.routes == source.routes &&
                self.serviceType == source.serviceType
        }
    }

    fileprivate struct PopulatorRoute: Codable, FetchableRecord, PersistableRecord, Differentiable {
        let id: String
        let title: String
        let color: String

        var differenceIdentifier: String {
            return id
        }

        func isContentEqual(to source: DatabasePopulator.PopulatorRoute) -> Bool {
            return self.id == source.id &&
                self.title == source.title &&
                self.color == source.color
        }
    }

    static func populateFromPrepackagedDbURL(_ url: URL, queue: GRDB.DatabaseQueue) throws {
        let prepackagedQueue = try GRDB.DatabaseQueue(path: url.path)

        // Check for new version of stops and routes
        let currentResourceVersion = try readResourceVersionForQueue(queue)
        let newResourceVersion = try readResourceVersionForQueue(prepackagedQueue)

        if newResourceVersion > currentResourceVersion {
            let currentStops = try readStopsForQueue(queue)
            let newStops = try readStopsForQueue(prepackagedQueue)
            let stopsStagedChangeset = StagedChangeset(source: currentStops, target: newStops)

            let currentRoutes = try readRoutesForQueue(queue)
            let newRoutes = try readRoutesForQueue(prepackagedQueue)
            let routesStagedChangeset = StagedChangeset(source: currentRoutes, target: newRoutes)

            try queue.write { db in

                // Update stops if changes aren't empty
                if !stopsStagedChangeset.isEmpty {
                    try updateStops(db,
                                    stagedChangeset: stopsStagedChangeset,
                                    currentStops: currentStops,
                                    newStops: newStops)
                }

                // Update routes if changes aren't empty
                if !routesStagedChangeset.isEmpty {
                    try updateRoutes(db,
                                     stagedChangeset: routesStagedChangeset,
                                     currentRoutes: currentRoutes,
                                     newRoutes: newRoutes)
                }

                // Update stop and route version
                try db.execute(sql: """
                                    INSERT INTO \(ResourceVersionsTable.tableName)
                                    (\(ResourceVersionsTable.versionColumn))
                                    VALUES (?)
                                    """, arguments: [newResourceVersion])
            }
        }
    }

    private static func readResourceVersionForQueue(_ queue: GRDB.DatabaseQueue) throws -> Int {
        return try queue.read { db -> Int in
            let sql = "SELECT MAX(\(ResourceVersionsTable.versionColumn)) FROM \(ResourceVersionsTable.tableName)"
            return try Int.fetchOne(db, sql: sql) ?? 0
        }
    }

    private static func readStopsForQueue(_ queue: GRDB.DatabaseQueue) throws -> [PopulatorStop] {
        return try queue.read { db -> [PopulatorStop] in
            let sql = "SELECT * FROM \(StopsTable.tableName)"
            return try PopulatorStop.fetchAll(db, sql: sql)
        }
    }

    private static func readRoutesForQueue(_ queue: GRDB.DatabaseQueue) throws -> [PopulatorRoute] {
        return try queue.read { db -> [PopulatorRoute] in
            let sql = "SELECT * FROM \(RoutesTable.tableName)"
            return try PopulatorRoute.fetchAll(db, sql: sql)
        }
    }

    private static func updateStops(_ db: GRDB.Database,
                                    stagedChangeset: StagedChangeset<[PopulatorStop]>,
                                    currentStops: [PopulatorStop],
                                    newStops: [PopulatorStop]) throws {

        for stopChangeset in stagedChangeset {

            if !stopChangeset.elementDeleted.isEmpty {
                try stopChangeset.elementDeleted.forEach { element in
                    try currentStops[element.element].delete(db)
                }
            }

            if !stopChangeset.elementInserted.isEmpty {
                try stopChangeset.elementInserted.forEach { element in
                    try newStops[element.element].insert(db)
                }
            }

            if !stopChangeset.elementUpdated.isEmpty {
                try stopChangeset.elementUpdated.forEach { element in
                    try newStops[element.element]
                        .update(db, columns: [
                            StopsTable.idColumn,
                            StopsTable.titleColumn,
                            StopsTable.latitudeColumn,
                            StopsTable.longitudeColumn,
                            StopsTable.routesColumn,
                            StopsTable.serviceTypeColumn
                        ])
                }
            }
        }
    }

    private static func updateRoutes(_ db: GRDB.Database,
                                     stagedChangeset: StagedChangeset<[PopulatorRoute]>,
                                     currentRoutes: [PopulatorRoute],
                                     newRoutes: [PopulatorRoute]) throws {

        for routeChangeset in stagedChangeset {

            if !routeChangeset.elementDeleted.isEmpty {
                try routeChangeset.elementDeleted.forEach { element in
                    try currentRoutes[element.element].delete(db)
                }
            }

            if !routeChangeset.elementInserted.isEmpty {
                try routeChangeset.elementInserted.forEach { element in
                    try newRoutes[element.element].insert(db)
                }
            }

            if !routeChangeset.elementUpdated.isEmpty {
                try routeChangeset.elementUpdated.forEach { element in
                    try newRoutes[element.element]
                        .update(db, columns: [
                            RoutesTable.idColumn,
                            RoutesTable.titleColumn,
                            RoutesTable.colorColumn
                        ])
                }
            }
        }
    }
}
