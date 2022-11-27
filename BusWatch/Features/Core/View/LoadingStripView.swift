//
//  LoadingStripView.swift
//  BusWatch
//
//  Created by Tyler Madonna on 9/22/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import UIKit

final class LoadingStripView: UIView {

    private var isAnimating = false

    private let progressBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Resources.Colors.appGold
        return view
    }()

    private var progressBarLeadingConstraint: NSLayoutConstraint?
    private var progressBarWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) cannot be used to create view")
    }

}

extension LoadingStripView {

    private func style() {
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = Resources.Colors.appBlack
    }

    private func layout() {
        addSubview(progressBarView)

        NSLayoutConstraint.activate([
            progressBarView.topAnchor.constraint(equalTo: topAnchor),
            progressBarView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        progressBarLeadingConstraint = progressBarView.leadingAnchor.constraint(equalTo: leadingAnchor)
        progressBarWidthConstraint = progressBarView.widthAnchor.constraint(equalToConstant: 0)
        progressBarLeadingConstraint?.isActive = true
        progressBarWidthConstraint?.isActive = true
    }

}

extension LoadingStripView {

    func startAnimating() {
        if !isAnimating {
            isAnimating = true
            animate()
        }
    }

    func stopAnimating() {
        isAnimating = false
    }

    private func animate() {
        // Call animate after viewDidLayoutSubviews in view controller
        // 430 is largest width (iPhone 14 pro max) just in case.
        let screenWidth = self.window?.bounds.width ?? 430
        progressBarLeadingConstraint?.constant = 0
        progressBarWidthConstraint?.constant = 0
        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.progressBarWidthConstraint?.constant = 0.6 * screenWidth
            self.layoutIfNeeded()
        }

        UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseInOut, animations: {
            self.progressBarLeadingConstraint?.constant = screenWidth
            self.layoutIfNeeded()
        }, completion: { _ in
            if self.isAnimating {
                self.animate()
            }
        })
    }

}
