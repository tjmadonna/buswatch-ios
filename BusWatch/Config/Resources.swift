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

        // MARK: - Navigation Bar

        static var navBarColor: UIColor {
            UIColor(named: "NavBarColor")!
        }

        // MARK: - Background

        static var backgroundColor: UIColor {
            UIColor(named: "BackgroundColor")!
        }

        // MARK: - Raised Background

        static var raisedBackgroundColor: UIColor {
            UIColor(named: "RaisedBackgroundColor")!
        }

        // MARK: - Dark Raised Background

        static var darkRaisedBackgroundColor: UIColor {
            UIColor(named: "DarkRaisedBackgroundColor")!
        }

        // MARK: - Decorator Background

        static var decoratorBackgroundColor: UIColor {
            UIColor(named: "DecoratorBackgroundColor")!
        }

        // MARK: - Decorator Text Background

        static var decoratorTextBackgroundColor: UIColor {
            UIColor(named: "DecoratorTextBackgroundColor")!
        }

        // MARK: - Capacity Image Color

        static var capacityImageColor: UIColor {
            UIColor(named: "CapacityImageColor")!
        }
    }
}
