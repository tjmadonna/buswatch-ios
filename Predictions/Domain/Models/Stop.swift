//
//  Stop.swift
//  Predictions
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

public struct Stop {
    let id: String
    let title: String
    let favorite: Bool
}

extension Stop: Equatable { }

extension Stop: CustomStringConvertible {

    public var description: String {
        return String(format: "id: %@, title: %@", id, title)
    }
}
