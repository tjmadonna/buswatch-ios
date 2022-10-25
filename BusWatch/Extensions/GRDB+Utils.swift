//
//  GRDB+Utils.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import GRDB

extension DatabaseQueue {

    enum Error: Swift.Error {
        case valueNotFound
    }

    func fetchAllValueObservationPublisherForSql<T: FetchableRecord>(
        _ sql: String,
        arguments: StatementArguments = StatementArguments()
    )-> AnyPublisher<[T], Swift.Error> {

        return ValueObservation.tracking { db in
            do {
                return try T.fetchAll(db, sql: sql, arguments: arguments)
            } catch {
                print(error)
                throw error
            }
        }
        .publisher(in: self)
        .eraseToAnyPublisher()
    }

    func fetchOneValueObservationPublisherForSql<T: FetchableRecord>(
        _ sql: String,
        arguments: StatementArguments = StatementArguments()
    )-> AnyPublisher<T, Swift.Error> {

        return ValueObservation.tracking { db in
            do {
                guard let value = try T.fetchOne(db, sql: sql, arguments: arguments) else {
                    throw DatabaseQueue.Error.valueNotFound
                }
                return value
            } catch {
                print(error)
                throw error
            }
        }
        .publisher(in: self)
        .eraseToAnyPublisher()
    }

}

extension GRDB.RowCursor {

    func compactMap<T>(_ closure: (Row) -> T?) -> [T] {
        var array = [T]()
        while let row = try? next() {
            if let element = closure(row) {
                array.append(element)
            }
        }
        return array
    }

}
