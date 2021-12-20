//
//  StopRepositoryRepresentable.swift
//  Predictions
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public protocol StopRepositoryRepresentable {

    func getStopById(_ stopId: String) -> AnyPublisher<Stop, Error>

    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error>

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error>

}
