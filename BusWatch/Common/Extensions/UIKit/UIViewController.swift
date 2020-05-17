//
//  UIViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

extension UIViewController {

    func presentAlertViewControllerWithTitle(_ title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in

        }))
        self.present(alert, animated: true, completion: nil)
    }
}
