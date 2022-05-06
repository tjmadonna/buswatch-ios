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

    private var databaseBuilder: GRDB.DatabaseQueue.Builder {
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

    lazy var database: Database = {
        return DatabaseImpl(databaseBuilder: databaseBuilder)
    }()

    lazy var userDefaults: UserDefaultsDataSource = {
        return UserDefaultsDataSourceImpl()
    }()

    // MARK: - Data Sources

    lazy var stopDatabaseDataSource: StopDatabaseDataSource = {
        return StopDatabaseDataSourceImpl(database: database)
    }()

    lazy var locationDatabaseDataSource: LocationDatabaseDataSource = {
        return LocationDatabaseDataSourceImpl(database: database)
    }()

    lazy var locationPermissionDataSource: LocationPermissionDataSource = {
        return LocationPermissionDataSourceImpl()
    }()

    lazy var predictionNetworkDataSource: PredictionNetworkDataSource = {
        let config = UrlConfig(scheme: NetworkConfig.scheme,
                               host: NetworkConfig.host,
                               apiKey: NetworkConfig.apiKey,
                               basePath: NetworkConfig.basePath)
        let urlSource = UrlSourceImpl(urlConfig: config)
        return PredictionNetworkDataSourceImpl(urlSource: urlSource)
    }()

    lazy var routeDatabaseDataSource: RouteDatabaseDataSource = {
        return RouteDatabaseDataSourceImpl(database: database)
    }()

    // MARK: - Repositories

    lazy var stopRepository: StopRepository = {
        return StopRepositoryImpl(database: stopDatabaseDataSource)
    }()

    lazy var locationRepository: LocationRepository = {
        return LocationRepositoryImpl(database: locationDatabaseDataSource,
                                      permissions: locationPermissionDataSource)
    }()

    lazy var predictionRepository: PredictionRepository = {
        return PredictionRepositoryImpl(predictionApi: predictionNetworkDataSource,
                                        routeDatabase: routeDatabaseDataSource)
    }()

    lazy var routeRepository: RouteRepository = {
        return RouteRepositoryImpl(database: routeDatabaseDataSource)
    }()
}
