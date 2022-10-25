//
//  DatabaseUpdater.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import DifferenceKit
import Foundation
import GRDB

enum DatabaseUpdater {

    fileprivate struct UpdaterStop: Codable, FetchableRecord, PersistableRecord, Differentiable {
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

        static var databaseTableName = StopsTable.tableName

        var differenceIdentifier: String {
            return id
        }

        func isContentEqual(to source: DatabaseUpdater.UpdaterStop) -> Bool {
            return self.id == source.id &&
                self.title == source.title &&
                self.latitude == source.latitude &&
                self.longitude == source.longitude &&
                self.routes == source.routes &&
                self.serviceType == source.serviceType
        }
    }

    fileprivate struct UpdaterRoute: Codable, FetchableRecord, PersistableRecord, Differentiable {
        let id: String
        let title: String
        let color: String

        var differenceIdentifier: String {
            return id
        }

        static var databaseTableName = RoutesTable.tableName

        func isContentEqual(to source: DatabaseUpdater.UpdaterRoute) -> Bool {
            return self.id == source.id &&
                self.title == source.title &&
                self.color == source.color
        }
    }

    static func updateFromPrepackagedDbURL(_ url: URL, queue: GRDB.DatabaseQueue) throws {
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
                do {
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
                } catch {
                    print(error)
                }
            }
        }
    }

    private static func readResourceVersionForQueue(_ queue: GRDB.DatabaseQueue) throws -> Int {
        return try queue.read { db -> Int in
            let sql = "SELECT MAX(\(ResourceVersionsTable.versionColumn)) FROM \(ResourceVersionsTable.tableName)"
            return try Int.fetchOne(db, sql: sql) ?? 0
        }
    }

    private static func readStopsForQueue(_ queue: GRDB.DatabaseQueue) throws -> [UpdaterStop] {
        return try queue.read { db -> [UpdaterStop] in
            let sql = "SELECT * FROM \(StopsTable.tableName)"
            return try UpdaterStop.fetchAll(db, sql: sql)
        }
    }

    private static func readRoutesForQueue(_ queue: GRDB.DatabaseQueue) throws -> [UpdaterRoute] {
        return try queue.read { db -> [UpdaterRoute] in
            let sql = "SELECT * FROM \(RoutesTable.tableName)"
            return try UpdaterRoute.fetchAll(db, sql: sql)
        }
    }

    private static func updateStops(_ db: GRDB.Database,
                                    stagedChangeset: StagedChangeset<[UpdaterStop]>,
                                    currentStops: [UpdaterStop],
                                    newStops: [UpdaterStop]) throws {

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
                let newStopDict = newStops.reduce(into: [String: UpdaterStop]()) { stopDict, stop in
                    stopDict[stop.id] = stop
                }

                try stopChangeset.elementUpdated.forEach { element in
                    let stop = currentStops[element.element]
                    try newStopDict[stop.id]?
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
                                     stagedChangeset: StagedChangeset<[UpdaterRoute]>,
                                     currentRoutes: [UpdaterRoute],
                                     newRoutes: [UpdaterRoute]) throws {

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
                let newRouteDict = newRoutes.reduce(into: [String: UpdaterRoute]()) { routeDict, route in
                    routeDict[route.id] = route
                }

                try routeChangeset.elementUpdated.forEach { element in
                    let route = currentRoutes[element.element]
                    try newRouteDict[route.id]?
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
