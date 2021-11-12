//
//  AppComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import UserDefaults
import Database
import Overview

final class AppComponent {

    private var database: DatabaseDataSourceRepresentable?

    private var userDefaults: UserDefaultsDataSourceRepresentable?

    func provideDatabaseDataSource() -> DatabaseDataSourceRepresentable {
        if let database = database {
            return database
        }
        let userDefaultsDataSource = provideUserDefaultsDataSource()
        let populator = DatabasePopulator(userDefaultaDataSource: userDefaultsDataSource)
        let database = DatabaseDataSource(databasePath: DatabaseConfig.url, databasePopulator: populator)
        self.database = database
        return database
    }

    func provideUserDefaultsDataSource() -> UserDefaultsDataSourceRepresentable {
        if let userDefaults = userDefaults {
            return userDefaults
        }
        let userDefaults = UserDefaultsDataSource()
        self.userDefaults = userDefaults
        return userDefaults
    }
}
