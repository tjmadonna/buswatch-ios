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

    private let loadingViewController: PredictionsLoadingViewController = {
        let viewController = PredictionsLoadingViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    private let dataViewController: PredictionsDataViewController = {
        let viewController = PredictionsDataViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    private let noDataViewController: PredictionsNoDataViewController = {
        let viewController = PredictionsNoDataViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    private var currentViewController: UIViewController?

    // MARK: -

    private let loadingView: LoadingStripView = {
        let view = LoadingStripView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    private let viewModel: PredictionsViewModel

    private var barItemHandler: PredictionsNavBarHandler?

    private var cancellables: [AnyCancellable] = []

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode =  .never
    }

    // MARK: - Setup

    private func setupViewController() {
        view.backgroundColor = .systemBackground
        navigationItem.backButtonDisplayMode = .minimal

        loadingViewController.view.isHidden = true
        dataViewController.view.isHidden = true
        noDataViewController.view.isHidden = true

        addChildViewController(loadingViewController)
        addChildViewController(dataViewController)
        addChildViewController(noDataViewController)

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 4),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupBarItems() {
        barItemHandler = PredictionsNavBarHandler(navigationItem: navigationItem)
        barItemHandler?.delegate = self
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
            case .noData:
                self?.renderNoDataStateForPredictions()
            case .error(let message):
                self?.renderErrorDataStateForMessage(message)
            }
        }
        .store(in: &cancellables)

        viewModel.loadingState.sink { [weak self] loading in
            if loading {
                self?.loadingView.startAnimating()
            } else {
                self?.loadingView.stopAnimating()
            }
        }
        .store(in: &cancellables)
    }

    // MARK: - State Rendering

    private func renderNavBarState(_ state: PredictionsNavBarState) {
        barItemHandler?.setTitleForNavBarState(state)
        barItemHandler?.setBarItemsForNavBarState(state)
    }

    private func renderLoadingDataState() {
        loadingViewController.view.isHidden = false
        currentViewController = loadingViewController
    }

    private func renderDataStateForPredictions(_ predictions: [Prediction]) {
        let shouldAnimate = currentViewController == dataViewController
        dataViewController.updatePredictions(predictions, animate: shouldAnimate)

        if !shouldAnimate {
            self.dataViewController.view.alpha = 0
            self.dataViewController.view.isHidden = false
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    self.currentViewController?.view.alpha = 0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    self.dataViewController.view.alpha = 1
                }
            }, completion: { _ in
                self.loadingViewController.view.isHidden = true
                self.noDataViewController.view.isHidden = true
            })
            self.currentViewController = dataViewController
        }
    }

    private func renderNoDataStateForPredictions() {
        guard self.currentViewController != noDataViewController else { return }

        self.noDataViewController.view.alpha = 0
        self.noDataViewController.view.isHidden = false
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.currentViewController?.view.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.noDataViewController.view.alpha = 1
            }
        }, completion: { _ in
            self.loadingViewController.view.isHidden = true
            self.dataViewController.view.isHidden = true
        })
        self.currentViewController = noDataViewController
    }

    private func renderErrorDataStateForMessage(_ message: String) {
        loadingViewController.view.isHidden = true
        dataViewController.view.isHidden = true
        currentViewController = nil
        presentAlertViewControllerWithTitle("An Error Occured", message: message)
    }
}

extension PredictionsViewController: PredictionsNavBarHandlerDelegate {

    func predictionsNavBarHandlerDidSelectFavoriteStop(_ predictionsNavBarHandler: PredictionsNavBarHandler) {
        viewModel.handleIntent(.toggleFavorited)
    }

    func predictionsNavBarHandlerDidSelectFilterRoutes(_ predictionsNavBarHandler: PredictionsNavBarHandler) {
        viewModel.handleIntent(.filterRoutesSelected)
    }

    func predictionsNavBarHandler(_ predictionsNavBarHandler: PredictionsNavBarHandler,
                                  wantsToPresentAlertController alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
    }
}
