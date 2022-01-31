//
//  DatabaseRouteMapper.swift
//  Database
//
//  Created by Tyler Madonna on 11/6/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class DatabaseRouteMapper {

    init() { }

    // MARK: - Database cursor

    func mapDatabaseRouteToStatementArguments(_ route: DatabaseRoute) -> StatementArguments {
        return StatementArguments([
            RoutesTable.idColumn: route.id,
            RoutesTable.titleColumn: route.title,
            RoutesTable.colorColumn: route.color
        ])
    }

    // MARK: - Decodable

    func mapDecodableRouteArrayToDatabaseRouteArray(_ decodableRoutes: [DecodableRoute]?) -> [DatabaseRoute] {
        guard let decodableRoutes = decodableRoutes else { return [] }
        return decodableRoutes.compactMap { mapDecodableRouteToDatabaseRoute($0) }
    }

    func mapDecodableRouteToDatabaseRoute(_ decodableRoute: DecodableRoute?) -> DatabaseRoute? {
        guard let decodableRoute = decodableRoute else { return nil }
        guard let id = decodableRoute.id else { return nil }
        guard let title = decodableRoute.title else { return nil }
        guard let color = decodableRoute.color else { return nil }

        return DatabaseRoute(
            id: id,
            title: title,
            color: color
        )
    }
}
