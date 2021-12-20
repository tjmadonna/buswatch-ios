//
//  UnfavoriteStop.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/3/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class UnfavoriteStop {

    private let stopRepository: StopRepositoryRepresentable

    public init(stopRepository: StopRepositoryRepresentable) {
        self.stopRepository = stopRepository
    }

    func execute(stopId: String) -> AnyPublisher<Void, Error> {
        return stopRepository.unfavoriteStop(stopId)
    }
}
