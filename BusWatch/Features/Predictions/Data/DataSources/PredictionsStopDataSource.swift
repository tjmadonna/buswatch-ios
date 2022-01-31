//
//  PredictionsStopDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/31/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol PredictionsStopDataSource {

    func getStopById(_ stopId: String) -> AnyPublisher<PredictionsStop, Error>

    func favoriteStop(_ stopId: String) -> AnyPublisher<Void, Error>

    func unfavoriteStop(_ stopId: String) -> AnyPublisher<Void, Error>

}
