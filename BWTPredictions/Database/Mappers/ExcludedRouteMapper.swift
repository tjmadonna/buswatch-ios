//
//  ExcludedRouteMapper.swift
//  BWTPredictions
//
//  Created by Tyler Madonna on 12/20/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB
import BWTDatabase

public final class ExcludedRouteMapper {

    public init() { }

    func mapDatabaseRowToRouteIdArray(_ row: Row?) -> [String] {
        guard let row = row else { return [] }
        guard let routeIdString = row[ExcludedRoutesTable.routesColumn] as? String else { return [] }

        return routeIdString.components(separatedBy: ExcludedRoutesTable.routesDelimiter)
    }
}
