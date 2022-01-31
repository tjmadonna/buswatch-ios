//
//  StopMapStopDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol StopMapStopDataSource {

    func getStopsInLocationBounds(_ locationBounds: StopMapLocationBounds) -> AnyPublisher<[StopMapStop], Error>

}
