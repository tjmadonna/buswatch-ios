//
//  GetStopsInLocationBounds.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class GetStopsInLocationBounds {

    private let stopRepository: StopRepositoryRepresentable

    public init(stopRepository: StopRepositoryRepresentable) {
        self.stopRepository = stopRepository
    }

    func execute(locationBounds: LocationBounds) -> AnyPublisher<[Stop], Error> {
        return stopRepository.getStopsInLocationBounds(locationBounds)
    }
}
