//
//  String+Utils.swift
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

    private static let wordDelimiters = [" ", "-"]

    private static let capitalizedExceptions = ["via"]

    func capitalizingOnlyFirstLetters() -> String {
        var str = self.lowercased().capitalized
        for delimiter in String.wordDelimiters {
            if str.contains(delimiter) {
                str = str.components(separatedBy: delimiter)
                    .map { word in
                        if String.capitalizedExceptions.contains(word.lowercased()) {
                            return word.lowercased()
                        }
                        return word.prefix(1).capitalized + word.dropFirst().lowercased()
                    }
                    .joined(separator: " ")
            }
        }
        return str
    }

}
