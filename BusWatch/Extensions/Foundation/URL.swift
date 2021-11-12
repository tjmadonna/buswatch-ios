//
//  URL.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/9/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

extension URL {

    func appendingDirectoryPathComponent(_ path: String, create: Bool) throws -> URL {
        let newPath = appendingPathComponent(path, isDirectory: true)
        if create {
            try FileManager.default.createDirectory(at: newPath, withIntermediateDirectories: true, attributes: nil)
        }
        return newPath
    }
}
