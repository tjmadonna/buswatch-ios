//
//  StyleConfig.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/24/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

enum Colors {

    // MARK: - Navigation Bar

    private static let navBarLight = UIColor(hexValue: 0x111E6C)

    private static let navBarDark = UIColor(hexValue: 0x1F1F1F)

    static var navBarColor: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return navBarDark
            } else {
                /// Return the color for Light Mode
                return navBarLight
            }
        }
    }

    // MARK: - Background

    private static let backgroundLight = UIColor(hexValue: 0xF1F1F1)

    private static let backgroundDark = UIColor(hexValue: 0x121212)

    static var backgroundColor: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return backgroundDark
            } else {
                /// Return the color for Light Mode
                return backgroundLight
            }
        }
    }

    // MARK: - Raised Background

    private static let raisedBackgroundLight = UIColor.white

    private static let raisedBackgroundDark = UIColor(hexValue: 0x1E1E1E)

    static var raisedBackgroundColor: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return raisedBackgroundDark
            } else {
                /// Return the color for Light Mode
                return raisedBackgroundLight
            }
        }
    }

    // MARK: - Decorator Background

    private static let decoratorBackgroundLight = UIColor(hexValue: 0xCFD2E1)

    private static let decoratorBackgroundDark = UIColor(hexValue: 0x787878)

    static var decoratorBackgroundColor: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return decoratorBackgroundDark
            } else {
                /// Return the color for Light Mode
                return decoratorBackgroundLight
            }
        }
    }

    // MARK: - Decorator Text Background

    private static let decoratorTextBackgroundLight = UIColor(hexValue: 0x5B5B5B)

    private static let decoratorTextBackgroundDark = UIColor(hexValue: 0xE8E8E8)

    static var decoratorTextBackgroundColor: UIColor {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return decoratorTextBackgroundDark
            } else {
                /// Return the color for Light Mode
                return decoratorTextBackgroundLight
            }
        }
    }
}
