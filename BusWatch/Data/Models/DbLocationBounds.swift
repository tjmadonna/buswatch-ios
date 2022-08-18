//
//  DbLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct DbLocationBounds {
    let north: Double
    let south: Double
    let west: Double
    let east: Double
}

extension DbLocationBounds {

    func toLocationBounds() -> LocationBounds {
        return LocationBounds(
            north: north,
            south: south,
            west: west,
            east: east
        )
    }

}

extension DbLocationBounds: Codable {

}

extension DbLocationBounds: FetchableRecord {

}
