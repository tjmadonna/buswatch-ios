//
//  Bundle+Utils.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/31/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation

extension Bundle {

    var appVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

}
