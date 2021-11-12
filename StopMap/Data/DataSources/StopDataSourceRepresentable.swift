//
//  StopDataSourceRepresentable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public protocol StopDataSourceRepresentable {

    func getStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[Stop], Error>
    
}
