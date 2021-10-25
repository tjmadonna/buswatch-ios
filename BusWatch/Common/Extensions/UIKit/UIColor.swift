//
//  UIColor.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(hexValue: Int) {
         self.init(hexValue: hexValue, alpha: 1.0)
    }

    convenience init(hexValue: Int, alpha: CGFloat) {
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    convenience init(hex: String, alpha: CGFloat = 1) {
        assert(hex[hex.startIndex] == "#", "Expected hex string of format #RRGGBB")

        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.index(after: hex.startIndex)  // skip #

        var rgb: Int = 0
        scanner.scanInt(&rgb)

        self.init(hexValue: rgb, alpha: alpha)
    }
}
