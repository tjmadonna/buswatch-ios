//
//  DbMinimalStop.swift
//  BusWatch
//
//  Created by Tyler Madonna on 8/8/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import GRDB

struct DbMinimalStop {
    let id: String
    let title: String
    let favorite: Bool
}

extension DbMinimalStop {

    func toMinimalStop() -> MinimalStop {
        return MinimalStop(
            id: id,
            title: title,
            favorite: favorite
        )
    }

}

extension DbMinimalStop: FetchableRecord {

    init(row: Row) {
        let id = row[StopsTable.idColumn] as String
        let title = row[StopsTable.titleColumn] as String
        let favoriteStop = row[FavoriteStopsTable.stopIdColumn] as? String

        self.init(
            id: id,
            title: title,
            favorite: favoriteStop != nil
        )
    }

}
