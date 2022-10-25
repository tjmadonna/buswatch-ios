//
//  PredictionsFavoriteStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

// MARK: - Database models
struct PredictionsFavoriteStop {
    let id: String
    let stopId: String?
}

extension PredictionsFavoriteStop: GRDB.FetchableRecord  {

    init(row: GRDB.Row) {
        let id = row[StopsTable.idColumn] as String
        let stopId = row[FavoriteStopsTable.stopIdColumn] as String?

        self.init(
            id: id,
            stopId: stopId
        )
    }

}
