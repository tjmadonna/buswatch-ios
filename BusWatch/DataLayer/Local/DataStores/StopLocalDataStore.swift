//
//  StopLocalDataStore.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Combine
import GRDB
import GRDBCombine

private enum StopLocalDataStoreError: Error {
    case stopNotFound
}

final class StopLocalDataStore {

    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func getStops() -> AnyPublisher<[Stop], Error> {
        let sql = """
        SELECT \(StopsTable.TableName).*, \(FavoriteStopsTable.TableName).\(FavoriteStopsTable.StopIdColumn)
        FROM \(StopsTable.TableName)
        LEFT JOIN \(FavoriteStopsTable.TableName)
        ON \(StopsTable.TableName).\(StopsTable.IDColumn) = \(FavoriteStopsTable.TableName).\(FavoriteStopsTable.StopIdColumn)
        """
        return valueObservationPublisherForSQL(sql, arguments: StatementArguments())
    }

    func getStopsInLocationBounds(_ bounds: LocationBounds) -> AnyPublisher<[Stop], Error> {
        let sql = """
        SELECT \(StopsTable.TableName).*, \(FavoriteStopsTable.TableName).\(FavoriteStopsTable.StopIdColumn)
        FROM \(StopsTable.TableName)
        LEFT JOIN \(FavoriteStopsTable.TableName)
        ON \(StopsTable.TableName).\(StopsTable.IDColumn) = \(FavoriteStopsTable.TableName).\(FavoriteStopsTable.StopIdColumn)
        WHERE \(StopsTable.LatitudeColumn) <= ?
        AND \(StopsTable.LatitudeColumn) >= ?
        AND \(StopsTable.LongitudeColumn) >= ?
        AND \(StopsTable.LongitudeColumn) <= ?
        """
        let arguments = StatementArguments([bounds.north, bounds.south, bounds.west, bounds.east])
        return valueObservationPublisherForSQL(sql, arguments: arguments)
    }

    func getFavoriteStops() -> AnyPublisher<[Stop], Error> {
        let sql = """
        SELECT \(StopsTable.TableName).*, \(FavoriteStopsTable.TableName).\(FavoriteStopsTable.StopIdColumn)
        FROM \(StopsTable.TableName)
        INNER JOIN \(FavoriteStopsTable.TableName)
        ON \(StopsTable.TableName).\(StopsTable.IDColumn) = \(FavoriteStopsTable.TableName).\(FavoriteStopsTable.StopIdColumn)
        """
        return valueObservationPublisherForSQL(sql, arguments: StatementArguments())
    }

    private func valueObservationPublisherForSQL(_ sql: String, arguments: StatementArguments) -> AnyPublisher<[Stop], Error> {
        return ValueObservation.tracking { db in
            let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
            return StopsTableMapper.mapCursorToStopList(cursor)
        }
        .publisher(in: dbQueue)
        .eraseToAnyPublisher()
    }

    func getStopById(_ id: String) -> AnyPublisher<Stop, Error> {
        let sql = """
        SELECT \(StopsTable.TableName).*, \(FavoriteStopsTable.TableName).\(FavoriteStopsTable.StopIdColumn)
        FROM \(StopsTable.TableName)
        LEFT JOIN \(FavoriteStopsTable.TableName)
        ON \(StopsTable.TableName).\(StopsTable.IDColumn) = \(FavoriteStopsTable.TableName).\(FavoriteStopsTable.StopIdColumn)
        WHERE \(StopsTable.TableName).\(StopsTable.IDColumn) = ?
        """
        let arguments = StatementArguments([id])
        return ValueObservation.tracking { db in
            let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
            guard let stop = StopsTableMapper.mapCursorRowToStop(row) else {
                throw StopLocalDataStoreError.stopNotFound
            }
            return stop
        }
        .publisher(in: dbQueue)
        .eraseToAnyPublisher()
    }

    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        let sql = "INSERT INTO \(FavoriteStopsTable.TableName) ( \(FavoriteStopsTable.StopIdColumn) ) VALUES ( ? )"
        return writePublisherForSQL(sql, arguments: [stopId])
    }

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error> {
        let sql = "DELETE FROM \(FavoriteStopsTable.TableName) WHERE \(FavoriteStopsTable.StopIdColumn) = ?"
        return writePublisherForSQL(sql, arguments: [stopId])
    }

    private func writePublisherForSQL(_ sql: String, arguments: StatementArguments) -> AnyPublisher<Void, Error> {
        return dbQueue.writePublisher { db in
            try db.execute(sql: sql, arguments: arguments)
        }
    }
}
