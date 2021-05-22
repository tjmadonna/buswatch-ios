//
//  AppComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

final class AppComponent {

    private var database: AppDatabase?

    private func appDatabase() throws -> AppDatabase {
        if let database = self.database {
            return database
        }
        let databaseUrl = try DatabaseConfig.url()
        let db = try AppDatabase(databasePath: databaseUrl)
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

    func predictionRemoteDataStore() -> PredictionRemoteDataStore {
        return PredictionRemoteDataStore()
    }
}
