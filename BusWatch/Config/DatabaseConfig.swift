//
//  DatabaseConfig.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

enum DatabaseConfig {

    static var url: URL {
        do {
            return try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingDirectoryPathComponent("Data", create: true)
                .appendingPathComponent("buswatch.sqlite")
        } catch {
            fatalError("Unable to create database: \(error)")
        }
    }
}
