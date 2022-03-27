//
//  LocationMappers.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

extension GRDB.Row {

    func toLocationBounds() -> LocationBounds? {
        guard let north = self[LastLocationTable.northBoundColumn] as? Double else { return nil }
        guard let south = self[LastLocationTable.southBoundColumn] as? Double else { return nil }
        guard let west = self[LastLocationTable.westBoundColumn] as? Double else { return nil }
        guard let east = self[LastLocationTable.eastBoundColumn] as? Double else { return nil }

        return LocationBounds(
            north: north,
            south: south,
            west: west,
            east: east
        )
    }
}
