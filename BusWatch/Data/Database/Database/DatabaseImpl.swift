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

    private let queueSubject = CurrentValueSubject<DatabaseQueue?, Error>(nil)

    // MARK: - Initialization

    init(databaseBuilder: GRDB.DatabaseQueue.Builder) {
        do {
            let queue = try databaseBuilder.build()
            queueSubject.value = queue
        } catch {
            queueSubject.send(completion: .failure(error))
        }
    }

    // MARK: - DatabaseDataSource

    var queuePublisher: AnyPublisher<DatabaseQueue, Error> {
        queueSubject.compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
