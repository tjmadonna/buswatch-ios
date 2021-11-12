//
//  UserDefaultsDataSource.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/23/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    public var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

public protocol UserDefaultsDataSourceRepresentable {

    var stopVersion: Int { get set }

    var routeVersion: Int { get set }

}

public final class UserDefaultsDataSource: UserDefaultsDataSourceRepresentable {

    @UserDefault(key: "stop_version", defaultValue: 0)
    public var stopVersion: Int

    @UserDefault(key: "route_version", defaultValue: 0)
    public var routeVersion: Int

    public init() { }
}
