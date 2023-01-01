//
//  OverviewService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import GRDB
import MapKit

// MARK: - Conformable
protocol OverviewServiceConformable {
    func observeFavoriteStops() -> AnyPublisher<[OverviewFavoriteStop], Swift.Error>
    func observeLastCoordinateRegion() -> AnyPublisher<MKCoordinateRegion, Swift.Error>
}

// MARK: - Service
final class OverviewService: OverviewServiceConformable {

    private let database: DatabaseConformable

    private let userDefaults: UserDefaults

    private let decoder = JSONDecoder()

    init(database: DatabaseConformable, userDefaults: UserDefaults = .standard) {
        self.database = database
        self.userDefaults = userDefaults
    }

}

// MARK: - OverviewServiceConformable
extension OverviewService {

    func observeFavoriteStops() -> AnyPublisher<[OverviewFavoriteStop], Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.idColumn), s.\(StopsTable.titleColumn), s.\(StopsTable.serviceTypeColumn),
        s.\(StopsTable.routesColumn), e.\(ExcludedRoutesTable.routesColumn) AS "excluded_routes"
        FROM \(StopsTable.tableName) AS s
        INNER JOIN \(FavoriteStopsTable.tableName) AS f
        ON s.\(StopsTable.idColumn) = f.\(FavoriteStopsTable.stopIdColumn)
        LEFT JOIN \(ExcludedRoutesTable.tableName) as e
        ON s.\(StopsTable.idColumn) = e.\(ExcludedRoutesTable.stopIdColumn)
        """
        return database.queue
            .fetchAllValueObservationPublisherForSql(sql)
    }

    func observeLastCoordinateRegion() -> AnyPublisher<MKCoordinateRegion, Swift.Error> {
        return userDefaults.publisher(for: \.lastCoordinateRegion)
            .map { [weak self] (data: Data?) -> MKCoordinateRegion? in
                guard let data = data else { return nil }
                return try? self?.decoder.decode(MKCoordinateRegion.self, from: data)
            }
            .replaceNil(with: defaultCoordinateRegion)
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
    }

}
