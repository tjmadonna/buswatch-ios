//
//  StopMapService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import GRDB
import MapKit

protocol StopMapServiceConformable {
    func getLastCoordinateRegion() -> Result<MKCoordinateRegion, Error>
    func updateLastCoordinateRegion(_ coordinateRegion: MKCoordinateRegion) -> Result<Void, Error>
    func getStopMarkersInCoordinateRegion(_ coordinateRegion: MKCoordinateRegion) async -> Result<[StopMarker], Error>
    func observeCurrentLocationPermission() -> AnyPublisher<CurrentLocationPermissionStatus, Never>
}

final class StopMapService: StopMapServiceConformable {

    private let database: DatabaseConformable

    private let userDefaults: UserDefaults

    private let encoder = JSONEncoder()

    private let decoder = JSONDecoder()

    init(database: DatabaseConformable, userDefaults: UserDefaults) {
        self.database = database
        self.userDefaults = userDefaults
    }

    func getLastCoordinateRegion() -> Result<MKCoordinateRegion, Error> {
        do {
            guard let data = userDefaults.lastCoordinateRegion else {
                return .success(defaultCoordinateRegion)
            }
            let region = try decoder.decode(MKCoordinateRegion.self, from: data)
            return .success(region)
        } catch {
            return .failure(error)
        }
    }

    func updateLastCoordinateRegion(_ coordinateRegion: MKCoordinateRegion) -> Result<Void, Error> {
        do {
            let data = try encoder.encode(coordinateRegion)
            userDefaults.lastCoordinateRegion = data
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }

    func getStopMarkersInCoordinateRegion(_ coordinateRegion: MKCoordinateRegion) async -> Result<[StopMarker], Error> {
        let sql = """
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), s.\(StopsTable.serviceTypeColumn),
        s.\(StopsTable.latitudeColumn), s.\(StopsTable.longitudeColumn),
        s.\(StopsTable.routesColumn), e.\(ExcludedRoutesTable.routesColumn) AS "excluded_routes"
        FROM \(StopsTable.tableName) AS s
        LEFT JOIN \(ExcludedRoutesTable.tableName) AS e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
        WHERE s.\(StopsTable.latitudeColumn) <= ?
        AND s.\(StopsTable.latitudeColumn) >= ?
        AND s.\(StopsTable.longitudeColumn) >= ?
        AND s.\(StopsTable.longitudeColumn) <= ?
        """
        let northBound = coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta
        let southBound = coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta
        let westBound = coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta // longitude negative
        let eastBound = coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta // longitude negative

        let arguments = StatementArguments([northBound, southBound, westBound, eastBound])
        do {
            let stops = try await database.queue.read { db in
                try StopMarker.fetchAll(db, sql: sql, arguments: arguments)
            }
            return .success(stops)
        } catch {
            return .failure(error)
        }
    }

    func observeCurrentLocationPermission() -> AnyPublisher<CurrentLocationPermissionStatus, Never> {
        return CurrentLocationPermissionPublisher()
            .eraseToAnyPublisher()
    }

}
