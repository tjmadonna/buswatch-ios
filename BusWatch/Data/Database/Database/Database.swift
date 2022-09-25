//
//  Database.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import GRDB

protocol Database {

    var queue: DatabaseQueue { get }

    var queuePublisher: AnyPublisher<DatabaseQueue, Error> { get }

}
