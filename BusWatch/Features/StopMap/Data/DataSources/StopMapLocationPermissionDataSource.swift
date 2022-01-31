//
//  StopMapLocationPermissionDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/27/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol StopMapLocationPermissionDataSource {

    func getCurrentLocationPermissionStatus() -> AnyPublisher<StopMapCurrentLocationPermissionStatus, Never>

}
