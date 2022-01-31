//
//  PredictionsStopMapper.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

final class PredictionsStopMapper {

    func mapDatabaseCursorToDomainStopArray(_ cursor: RowCursor) -> [PredictionsStop] {
        var stops = [PredictionsStop]()
        while let cursorRow = try? cursor.next() {
            if let stop = mapDatabaseRowToDomainStop(cursorRow) {
                stops.append(stop)
            }
        }
        return stops
    }

    func mapDatabaseRowToDomainStop(_ row: Row?) -> PredictionsStop? {
        guard let row = row else { return nil }
        guard let id = row[StopsTable.idColumn] as? String else { return nil }
        guard let title = row[StopsTable.titleColumn] as? String else { return nil }

        return PredictionsStop(
            id: id,
            title: title,
            favorite: row[FavoriteStopsTable.stopIdColumn] != nil
        )
    }
}
