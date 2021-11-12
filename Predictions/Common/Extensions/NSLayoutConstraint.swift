//
//  NSLayoutConstraint.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/22/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {

    /// Returns the constraint sender with the passed priority.
    ///
    /// - Parameter priority: The priority to be set.
    /// - Returns: The sended constraint adjusted with the new priority.
    func usingPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
