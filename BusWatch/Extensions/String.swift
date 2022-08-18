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

    func capitalizingOnlyFirstLetters() -> String {
        let words = components(separatedBy: " ")
            .map { word in word.prefix(1).capitalized + word.dropFirst().lowercased()
        }
        return words.joined(separator: " ")
    }

    mutating func capitalizeOnlyFirstLetter() {
        self = self.capitalizingOnlyFirstLetter()
    }
}
