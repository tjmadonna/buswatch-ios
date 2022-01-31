//
//  UIColor.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/3/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init?(hex: String?, alpha: CGFloat = 1) {
        guard let hex = hex else { return nil }

        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            return nil
        }

        var rgb: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgb)

        let red = (rgb >> 16) & 0xFF
        let green = (rgb >> 8) & 0xFF
        let blue = rgb & 0xFF

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}
