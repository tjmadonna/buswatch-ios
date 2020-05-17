//
//  DefaultLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/7/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

enum DefaultLocationBounds {

    static var arguments: StatementArguments {
        return StatementArguments([
            LastLocationTable.IDColumn: 1,
            LastLocationTable.NorthBoundColumn: 40.44785576556447,
            LastLocationTable.SouthBoundColumn: 40.4281598420304,
            LastLocationTable.WestBoundColumn: -80.00565690773512,
            LastLocationTable.EastBoundColumn: -79.98956365216942
        ])
    }
}
