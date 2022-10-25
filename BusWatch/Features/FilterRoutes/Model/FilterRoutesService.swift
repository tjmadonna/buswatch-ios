//
//  FilterRoutesService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import GRDB

// MARK: - Service
protocol FilterRoutesServiceConformable {
    func observeFilterableRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterRoute], Swift.Error>
    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) async -> Result<Void, Swift.Error>
}

final class FilterRoutesService: FilterRoutesServiceConformable {

    private let database: DatabaseConformable

    private weak var eventCoordinator: FilterRoutesEventCoordinator?

    init(database: DatabaseConformable, eventCoordinator: FilterRoutesEventCoordinator) {
        self.database = database
        self.eventCoordinator = eventCoordinator
    }

    func observeFilterableRoutesForStopId(_ stopId: String) -> AnyPublisher<[FilterRoute], Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.routesColumn), e.\(ExcludedRoutesTable.routesColumn)
        AS \(ExcludedRoutesTable.routesColumnAlt)
        FROM \(StopsTable.tableName) AS s
        LEFT JOIN \(ExcludedRoutesTable.tableName) AS e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
        WHERE s.\(StopsTable.idColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return ValueObservation.tracking { db in
            let filterRouteWithExclusions = try FilterRouteWithExclusions.fetchOne(db, sql: sql, arguments: arguments)
            let excludedRouteIds = Set(filterRouteWithExclusions?.excludedRoutes ?? [])
            let filterRoutes = filterRouteWithExclusions?.routes.map { routeId in
                return FilterRoute(id: routeId, filtered: excludedRouteIds.contains(routeId))
            }
            return filterRoutes ?? []
        }
        .publisher(in: database.queue)
        .eraseToAnyPublisher()
    }

    func updateExcludedRouteIdsForStopId(_ stopId: String, routeIds: [String]) async -> Result<Void, Swift.Error> {
        let sql: String
        let arguments: StatementArguments

        if routeIds.isEmpty {
            sql = "DELETE FROM \(ExcludedRoutesTable.tableName) WHERE \(ExcludedRoutesTable.stopIdColumn) = ?"
            arguments = StatementArguments([stopId])
        } else {
            sql = """
                  INSERT INTO \(ExcludedRoutesTable.tableName)
                  (\(ExcludedRoutesTable.stopIdColumn), \(ExcludedRoutesTable.routesColumn))
                  VALUES (?, ?) ON CONFLICT (\(ExcludedRoutesTable.stopIdColumn))
                  DO UPDATE SET \(ExcludedRoutesTable.routesColumn) = ?
                  """
            let routeIdString = routeIds.joined(separator: ExcludedRoutesTable.routesDelimiter)
            arguments = StatementArguments([stopId, routeIdString, routeIdString])
        }

        do {
            try await database.queue.write { db in
                try db.execute(sql: sql, arguments: arguments)
            }
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }

}
