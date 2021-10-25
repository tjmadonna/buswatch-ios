//
//  AppComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

final class AppComponent {

    let userDefaultsStore = UserDefaultStore()

    private var database: AppDatabase?

    private func appDatabase() throws -> AppDatabase {
        if let database = self.database {
            return database
        }
        let populator = DatabasePopulator(userDefaultStore: userDefaultsStore)
        let databaseUrl = try DatabaseConfig.url()
        let db = try AppDatabase(databasePath: databaseUrl, populator: populator)
        self.database = db
        return db
    }

    func stopLocalDataStore() throws -> StopLocalDataStore {
        let database = try appDatabase()
        return StopLocalDataStore(dbQueue: database.queue)
    }

    func locationLocalDataStore() throws -> LocationLocalDataStore {
        let database = try appDatabase()
        return LocationLocalDataStore(dbQueue: database.queue)
    }

    func routeLocalDataStore() throws -> RouteLocalDataStore {
        let database = try appDatabase()
        return RouteLocalDataStore(dbQueue: database.queue)
    }

    func predictionRemoteDataStore() throws -> PredictionRemoteDataStore {
        let routeDataStore = try routeLocalDataStore()
        return PredictionRemoteDataStore(routesLocalDataStore: routeDataStore)
    }
}
