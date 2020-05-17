//
//  LastLocationTableMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import GRDB

enum LastLocationTableMapper {

    static func mapCursorRowToLocationBounds(_ row: Row?) -> LocationBounds? {
        guard let row = row else { return nil }
        guard let north = row[LastLocationTable.NorthBoundColumn] as? Double else { return nil }
        guard let south = row[LastLocationTable.SouthBoundColumn] as? Double else { return nil }
        guard let west = row[LastLocationTable.WestBoundColumn] as? Double else { return nil }
        guard let east = row[LastLocationTable.EastBoundColumn] as? Double else { return nil }

        return LocationBounds(north: north, south: south, west: west, east: east)
    }
}

