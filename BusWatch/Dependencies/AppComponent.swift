//
//  AppComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import BWTUserDefaults
import BWTDatabase
import BWTOverview

final class AppComponent {

    private lazy var database: DatabaseDataSourceRepresentable = {
        let userDefaultsDataSource = self.userDefaults
        let populator = DatabasePopulator(userDefaultaDataSource: userDefaultsDataSource)
        return DatabaseDataSource(databasePath: DatabaseConfig.url, databasePopulator: populator)
    }()

    private lazy var userDefaults: UserDefaultsDataSourceRepresentable = {
        return UserDefaultsDataSource()
    }()

    func provideDatabaseDataSource() -> DatabaseDataSourceRepresentable {
        return database
    }

    func provideUserDefaultsDataSource() -> UserDefaultsDataSourceRepresentable {
        return userDefaults
    }
}
