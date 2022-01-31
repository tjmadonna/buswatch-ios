//
//  AppComponent.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

final class AppComponent {

    private lazy var database: DatabaseDataSource = {
        let userDefaultsDataSource = self.userDefaults
        let populator = DatabasePopulator(userDefaultaDataSource: userDefaultsDataSource)
        return DatabaseDataSourceImpl(databasePath: DatabaseConfig.url, databasePopulator: populator)
    }()

    private lazy var userDefaults: UserDefaultsDataSource = {
        return UserDefaultsDataSourceImpl()
    }()

    func provideDatabaseDataSource() -> DatabaseDataSource {
        return database
    }

    func provideUserDefaultsDataSource() -> UserDefaultsDataSource {
        return userDefaults
    }
}
