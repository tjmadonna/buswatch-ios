//
//  StopMapStopRepository.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/26/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol StopMapStopRepository {

    func getStopsInLocationBounds(_ locationBounds: StopMapLocationBounds) -> AnyPublisher<[StopMapStop], Error>

}
