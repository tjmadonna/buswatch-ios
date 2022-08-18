//
//  Resources.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

enum Resources {

    enum Images {
        static let capacityEmpty = "EmptyCapacityIcon"
        static let capacityHalfEmpty = "HalfEmptyCapacityIcon"
        static let capacityFull = "FullCapacityIcon"
    }

    enum Strings {
        static let arrivingNow = "Arriving Now"
        static let arrivingIn1Min = "Arriving In 1 minute"
        static func arrivingInNMins(_ minutes: Int) -> String {
            return String(format: "Arriving In %d minutes", minutes)
        }

        static func predictionTitleNoRoute(_ destination: String, _ routeDirection: String) -> String {
            return String(format: "%@ (%@)", destination, routeDirection)
        }
        static func predictionTitleWithRoute(_ routeTitle: String,
                                             _ destination: String,
                                             _ routeDirection: String) -> String {
            return String(format: "%@ to %@ (%@)", routeTitle, destination, routeDirection)
        }
    }

    enum Colors {

        static var appGold: UIColor {
            UIColor(named: "AppGold")!
        }

        static var appBlack: UIColor {
            UIColor(named: "AppBlack")!
        }

        static var capacity: UIColor {
            UIColor(named: "Capacity")!
        }
    }
}
