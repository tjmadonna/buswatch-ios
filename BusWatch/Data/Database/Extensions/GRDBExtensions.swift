//
//  GRDBExtensions.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

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
