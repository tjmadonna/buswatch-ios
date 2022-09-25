//
//  DatabaseDataSourceImpl.swift
//  BusWatch
//
//  Created by Tyler Madonna on 1/30/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

final class DatabaseImpl: Database {

    // MARK: - Properties

    static let databaseVersion = "5"

    let queue: DatabaseQueue

    // MARK: - Initialization

    init(databaseBuilder: GRDB.DatabaseQueue.Builder) throws {
        self.queue = try databaseBuilder.build()
    }

    // MARK: - DatabaseDataSource

    var queuePublisher: AnyPublisher<DatabaseQueue, Error> {
        return CurrentValueSubject(queue)
            .eraseToAnyPublisher()
    }
}
