//
//  LocationPermissionDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

protocol LocationPermissionDataSource {

    func getCurrentLocationPermissionStatus() -> AnyPublisher<CurrentLocationPermissionStatus, Never>

}
