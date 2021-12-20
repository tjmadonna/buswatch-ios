//
//  GetStopById.swift
//  Predictions
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class GetStopById {

    private let stopRepository: StopRepositoryRepresentable

    public init(stopRepository: StopRepositoryRepresentable) {
        self.stopRepository = stopRepository
    }

    func execute(stopId: String) -> AnyPublisher<Stop, Error> {
        return stopRepository.getStopById(stopId)
    }
}
