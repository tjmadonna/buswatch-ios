//
//  String.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/7/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

extension String {

    func capitalizingOnlyFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst().lowercased()
    }

    mutating func capitalizeOnlyFirstLetter() {
        self = self.capitalizingOnlyFirstLetter()
    }
}
