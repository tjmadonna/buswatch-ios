//
//  FavoriteStop.swift
//  Overview
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

public struct FavoriteStop {
    let id: String
    let title: String
    let routes: [String]
}

extension FavoriteStop: Equatable { }

extension FavoriteStop: CustomStringConvertible {
    
    public var description: String {
        return String(format: "id: %@, title: %@", id, title)
    }
}
