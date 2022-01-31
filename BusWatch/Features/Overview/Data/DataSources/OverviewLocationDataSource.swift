//
//  OverviewLocationDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/29/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol OverviewLocationDataSource {

    func getLastLocationBounds() -> AnyPublisher<OverviewLocationBounds, Error>

}
