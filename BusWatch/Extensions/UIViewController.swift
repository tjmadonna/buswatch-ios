//
//  UIViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/3/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit

extension UIViewController {

    func presentAlertViewControllerWithTitle(_ title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in

        }))
        self.present(alert, animated: true, completion: nil)
    }

    func addChildViewController(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)

        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        child.didMove(toParent: self)
    }
}
