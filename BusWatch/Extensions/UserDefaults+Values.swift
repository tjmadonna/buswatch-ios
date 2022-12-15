//
//  UserDefaults+Utils.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

extension UserDefaults {

    @objc dynamic var lastCoordinateRegion: Data? {
        get {
            data(forKey: "last_coordinate_region")
        }
        set(newValue) {
            set(newValue, forKey: "last_coordinate_region")
        }
    }

    @objc dynamic var stopVersion: Int {
        get {
            integer(forKey: "stop_version")
        }
        set(newValue) {
            set(newValue, forKey: "stop_version")
        }
    }

    @objc dynamic var routeVersion: Int {
        get {
            integer(forKey: "route_version")
        }
        set(newValue) {
            set(newValue, forKey: "route_version")
        }
    }

    @objc dynamic var appVersion: String {
        get {
            string(forKey: "app_version") ?? ""
        }
        set(newValue) {
            set(newValue, forKey: "app_version")
        }
    }

    @objc dynamic var buildVersion: String {
        get {
            string(forKey: "build_version") ?? ""
        }
        set(newValue) {
            set(newValue, forKey: "build_version")
        }
    }
}
