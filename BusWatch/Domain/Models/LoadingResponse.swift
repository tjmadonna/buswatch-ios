//
//  LoadingResponse.swift
//  BusWatch
//
//  Created by Tyler Madonna on 9/23/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

enum LoadingResponse<T> {
    case loading
    case success(T)
    case failure(Error)
}
