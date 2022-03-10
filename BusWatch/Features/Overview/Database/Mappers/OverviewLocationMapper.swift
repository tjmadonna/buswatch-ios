//
//  OverviewLocationMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class OverviewLocationMapper {

    func mapDatabaseRowToDomainLocationBounds(_ row: Row?) -> OverviewLocationBounds? {
        guard let row = row else { return nil }
        guard let north = row[LastLocationTable.northBoundColumn] as? Double else { return nil }
        guard let south = row[LastLocationTable.southBoundColumn] as? Double else { return nil }
        guard let west = row[LastLocationTable.westBoundColumn] as? Double else { return nil }
        guard let east = row[LastLocationTable.eastBoundColumn] as? Double else { return nil }

        return OverviewLocationBounds(north: north, south: south, west: west, east: east)
    }
}
