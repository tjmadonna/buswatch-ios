//
//  UrlSource.swift
//  Network
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

protocol UrlSource {

    func authenticatedPredictionsURLForStopId(_ stopId: String, serviceType: ServiceType) -> URL

}
