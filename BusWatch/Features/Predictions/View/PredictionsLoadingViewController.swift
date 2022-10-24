//
//  PredictionsLoadingViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/22/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit

final class PredictionsLoadingViewController: UIViewController {

    // MARK: - Views

    private let loadingIndicatorView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        return loadingView
    }()

    // MARK: - Initialization

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("PredictionsLoadingViewController Error: View Controller cannot be initialized with init(coder:)")
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupSubviews()
    }

    // MARK: - Setup

    private func setupViewController() {
        loadingIndicatorView.startAnimating()
    }

    private func setupSubviews() {
        view.addSubview(loadingIndicatorView)

        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}