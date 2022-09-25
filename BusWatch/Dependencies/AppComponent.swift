//
//  AppComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class AppComponent {

    private static var databaseBuilder: GRDB.DatabaseQueue.Builder {
        return GRDB.DatabaseQueue.Builder(databasePath: DatabaseConfig.url, version: DatabaseImpl.databaseVersion)
            .createFromFile(DatabaseConfig.prePackagedDbUrl)
            .addMigration("1", migration: DatabaseMigration.migrateToVersion1)
            .addMigration("2", migration: DatabaseMigration.migrateToVersion2)
            .addMigration("3", migration: DatabaseMigration.migrateToVersion3)
            .addMigration("4", migration: DatabaseMigration.migrateToVersion4)
            .addMigration("5", migration: DatabaseMigration.migrateToVersion5)
            .addPopulator { queue in
                try DatabasePopulator.populateFromPrepackagedDbURL(DatabaseConfig.prePackagedDbUrl, queue: queue)
            }
    }

    let database: Database

    init() throws {
        self.database = try DatabaseImpl(databaseBuilder: AppComponent.databaseBuilder)
    }

    lazy var userDefaults: UserDefaultsDataSource = {
        return UserDefaultsDataSourceImpl()
    }()

    lazy var urlSession: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        return URLSession(configuration: sessionConfig)
    }()

    // MARK: - Data Sources

    lazy var stopDatabaseDataSource: StopDbDataSource = {
        return StopDbDataSourceImpl(database: database)
    }()

    lazy var locationDatabaseDataSource: LocationDbDataSource = {
        return LocationDbDataSourceImpl(database: database)
    }()

    lazy var locationPermissionDataSource: PermissionDataSource = {
        return PermissionDataSourceImpl()
    }()

    lazy var predictionNetworkDataSource: NetworkDataSource = {
        let config = UrlConfig(scheme: NetworkConfig.scheme,
                               host: NetworkConfig.host,
                               apiKey: NetworkConfig.apiKey,
                               basePath: NetworkConfig.basePath)
        let urlSource = UrlSourceImpl(urlConfig: config)
        return NetworkDataSourceImpl(urlSource: urlSource, urlSession: urlSession)
    }()

    lazy var routeDatabaseDataSource: RouteDbDataSource = {
        return RouteDbDataSourceImpl(database: database)
    }()

    // MARK: - Services

    lazy var stopService: StopService = {
        return StopServiceImpl(dbDataSource: stopDatabaseDataSource)
    }()

    lazy var locationService: LocationService = {
        return LocationServiceImpl(dbDataSource: locationDatabaseDataSource)
    }()

    lazy var predictionService: PredictionService = {
        return PredictionServiceImpl(networkDataSource: predictionNetworkDataSource,
                                     routeDataSource: routeDatabaseDataSource)
    }()

    lazy var routeService: RouteService = {
        return RouteServiceImpl(dbDataSource: routeDatabaseDataSource)
    }()
}
