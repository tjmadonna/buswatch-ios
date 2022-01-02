//
//  PredictionsViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit
import Combine

public final class PredictionsViewController: UIViewController {

    // MARK: - Child View Controllers

    private lazy var loadingViewController: LoadingViewController = {
        let viewController = LoadingViewController(style: self.style)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    private lazy var dataViewController: PredictionsDataViewController = {
        let viewController = PredictionsDataViewController(style: self.style)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    private lazy var noDataViewController: PredictionsNoDataViewController = {
        let viewController = PredictionsNoDataViewController(style: self.style)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()

    private var currentViewController: UIViewController? = nil

    // MARK: - Properties

    private let viewModel: PredictionsViewModel

    private let style: PredictionsStyleRepresentable

    private var barItemHandler: PredictionsNavBarHandler?

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    public init(viewModel: PredictionsViewModel, style: PredictionsStyleRepresentable) {
        self.viewModel = viewModel
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("PredictionsViewController Error: View Controller cannot be initialized with init(coder:)")
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - UIViewController Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupBarItems()
        setupObservers()
    }

    // MARK: - Setup

    private func setupViewController() {
        title = ""
        view.backgroundColor = style.backgroundColor

        loadingViewController.view.isHidden = true
        dataViewController.view.isHidden = true
        noDataViewController.view.isHidden = true

        addChildViewController(loadingViewController)
        addChildViewController(dataViewController)
        addChildViewController(noDataViewController)
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

    private func renderDataStateForPredictions(_ predictions: [PresentationPrediction]) {
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
