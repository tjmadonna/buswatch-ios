//
//  UserDefaultStore.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/23/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

final class UserDefaultStore {

    @UserDefault(key: "stop_version", defaultValue: 0)
    var stopVersion: Int

}
