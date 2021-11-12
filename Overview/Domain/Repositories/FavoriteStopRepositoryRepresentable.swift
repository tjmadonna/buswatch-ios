//
//  FavoriteStopRepositoryRepresentable.swift
//  Overview
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public protocol FavoriteStopRepositoryRepresentable {

    func getFavoriteStops() -> AnyPublisher<[FavoriteStop], Error>

}
