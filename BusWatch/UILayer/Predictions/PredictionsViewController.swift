//
//  PredictionsViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit
import Combine

final class PredictionsViewController: UIViewController {

    // MARK: - Child View Controllers

    private let dataViewController: PredictionsDataViewController = {
        let viewController = PredictionsDataViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    private let loadingViewController: LoadingViewController = {
        let viewController = LoadingViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    private var currentViewController: UIViewController? = nil

    // MARK: - Properties

    private let viewModel: PredictionsViewModel

    private var cancellables: [AnyCancellable] = []

    // MARK: - Views

    private lazy var favoritedBarButton: UIBarButtonItem = {
        let starImage = UIImage(systemName: "star")
        return UIBarButtonItem(image: starImage,
                               style: .plain,
                               target: self,
                               action: #selector(handleFavoriteToggleTouch(sender:)))
    }()

    // MARK: - Initialization

    init(viewModel: PredictionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("PredictionsViewController Error: View Controller cannot be initialized with init(coder:)")
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupBarItems()
        setupObservers()
    }

    // MARK: - Setup

    private func setupViewController() {
        view.backgroundColor = Colors.backgroundColor
        loadingViewController.view.isHidden = true
        dataViewController.view.isHidden = true

        addChildViewController(loadingViewController)
        addChildViewController(dataViewController)
    }

    private func setupBarItems() {
        navigationItem.rightBarButtonItem = favoritedBarButton
    }

    private func setupObservers() {
        viewModel.navBarState
            .sink { [weak self] state in
                self?.renderNavBarState(state)
        }
        .store(in: &cancellables)

        viewModel.dataState.sink { [weak self] state in
            switch state {
            case .loading:
                self?.renderLoadingDataState()
            case .data(let predictionItems):
                self?.renderDataStateForPredictions(predictionItems)
            case .error(let message):
                self?.renderErrorDataStateForMessage(message)
            }
        }
        .store(in: &cancellables)
    }

    // MARK: - Button handling

    @objc private func handleFavoriteToggleTouch(sender: Any) {
        viewModel.handleIntent(.toggleFavorited)
    }

    // MARK: - State Rendering

    private func renderNavBarState(_ state: PredictionsNavBarState) {
        let image = state.favorited ? UIImage(systemName: "star.fill") :  UIImage(systemName: "star")
        self.favoritedBarButton.image = image
    }

    private func renderLoadingDataState() {
        loadingViewController.view.isHidden = false
        currentViewController = loadingViewController
    }

    private func renderDataStateForPredictions(_ predictionItems: [PredictionItem]) {
        let shouldAnimate = currentViewController == dataViewController
        dataViewController.updatePredictions(predictionItems, animate: shouldAnimate)

        if !shouldAnimate {
            self.dataViewController.view.alpha = 0
            self.dataViewController.view.isHidden = false
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    self.loadingViewController.view.alpha = 0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    self.dataViewController.view.alpha = 1
                }
            }, completion: { _ in
                self.loadingViewController.view.isHidden = true
            })
            self.currentViewController = dataViewController
        }
    }

    private func renderErrorDataStateForMessage(_ message: String) {
        loadingViewController.view.isHidden = true
        dataViewController.view.isHidden = true
        currentViewController = nil
        presentAlertViewControllerWithTitle("An Error Occured", message: message)
    }
}
