//
//  LocationLocalDataStore.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Combine
import GRDB
import GRDBCombine
import CoreLocation

private enum LocationLocalDataStoreError: Error {
    case lastLocationNotFound
}

final class LocationLocalDataStore {

    // MARK: - Properties

    private let dbQueue: DatabaseQueue

    private let locationManager: CLLocationManager

    // MARK: - Initialization

    init(dbQueue: DatabaseQueue, locationManager: CLLocationManager = CLLocationManager()) {
        self.dbQueue = dbQueue
        self.locationManager = locationManager
    }

    func getLastLocationBounds() -> AnyPublisher<LocationBounds, Error> {
        let sql = "SELECT * FROM \(LastLocationTable.TableName)"
        return ValueObservation.tracking { db in
            let row = try Row.fetchOne(db, sql: sql)
            guard let lastLocation = LastLocationTableMapper.mapCursorRowToLocationBounds(row) else {
                throw LocationLocalDataStoreError.lastLocationNotFound
            }
            return lastLocation
        }
        .publisher(in: dbQueue)
        .eraseToAnyPublisher()
    }

    func saveLastLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<Void, Error> {
        let sql = """
        INSERT INTO \(LastLocationTable.TableName) (\(LastLocationTable.AllColumns))
        VALUES (?, ?, ?, ?, ?) ON CONFLICT(\(LastLocationTable.IDColumn))
        DO UPDATE SET
        \(LastLocationTable.NorthBoundColumn) = ?,
        \(LastLocationTable.SouthBoundColumn) = ?,
        \(LastLocationTable.WestBoundColumn) = ?,
        \(LastLocationTable.EastBoundColumn) = ?
        """

        return dbQueue.writePublisher { db in
            try db.execute(sql: sql, arguments: [
                1,
                locationBounds.north,
                locationBounds.south,
                locationBounds.west,
                locationBounds.east,
                locationBounds.north,
                locationBounds.south,
                locationBounds.west,
                locationBounds.east
            ])
        }
    }

    // MARK: - Current Location

    func getCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never> {
        return LocationPublisher(locationManager: locationManager)
            .eraseToAnyPublisher()
    }
}

enum CurrentLocationPermissionStatus {
    case granted
    case denied
}

struct LocationPublisher: Publisher {

    typealias Output = CurrentLocationPermissionStatus

    typealias Failure = Never

    private let locationManager: CLLocationManager

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        subscriber.receive(subscription: Inner(downstream: subscriber, locationManager: locationManager))
    }

    private final class Inner<S>: NSObject, Subscription, CLLocationManagerDelegate
            where S: Subscriber, S.Input == CurrentLocationPermissionStatus, S.Failure == Never {

        private let locationManager: CLLocationManager

        private var downstream: S?

        init(downstream: S, locationManager: CLLocationManager = CLLocationManager()) {
            self.downstream = downstream
            self.locationManager = locationManager
            super.init()
            self.locationManager.delegate = self
        }

        func request(_ demand: Subscribers.Demand) {
            sendCurrentLocationPermissionStatus()
        }

        func cancel() {
            downstream?.receive(completion: .finished)
            locationManager.delegate = nil
            downstream = nil
        }

        private func sendCurrentLocationPermissionStatus() {
            let status = getCurrentLocationPermissionStatus()
            _ = downstream?.receive(status)
        }

        private func getCurrentLocationPermissionStatus() -> CurrentLocationPermissionStatus {
            guard CLLocationManager.locationServicesEnabled() else { return .denied }

            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                return .granted
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                return .denied
            default:
                locationManager.stopUpdatingLocation()
                return .denied
            }
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            sendCurrentLocationPermissionStatus()
        }
    }
}
