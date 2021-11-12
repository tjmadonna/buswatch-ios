//
//  StopRepositoryRepresentable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/26/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public protocol StopRepositoryRepresentable {

    func getStopsInLocationBounds(_ locationBounds: LocationBounds) -> AnyPublisher<[Stop], Error>

}
