//
//  PredictionsMainViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit
import Combine

final class PredictionsMainViewController: UITableViewController {

    // MARK: - Properties

    private let viewModel: PredictionsViewModel

    private var predictionItems = [PredictionItem]()

    private var cancellables: [AnyCancellable] = []

    // MARK: - Views

    private lazy var favoritedBarButton: UIBarButtonItem = {
        let starImage = UIImage(systemName: "star")
        return UIBarButtonItem(image: starImage,
                               style: .plain,
                               target: self,
                               action: #selector(handleFavoriteToggleTouch(sender:)))
    }()

    private let loadingIndicatorView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        return loadingView
    }()

    // MARK: - Initialization

    init(viewModel: PredictionsViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
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
        setupSubviews()
        setupTableView()
        setupBarItems()
        setupObservers()
    }

    // MARK: - Setup

    private func setupViewController() {
        view.backgroundColor = Colors.backgroundColor
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(PredictionCell.self, forCellReuseIdentifier: PredictionCell.ReuseId)
        tableView.register(SimpleMessageCell.self, forCellReuseIdentifier: SimpleMessageCell.ReuseId)
    }

    private func setupSubviews() {
        let backgroundView = UIView()

        backgroundView.addSubview(loadingIndicatorView)

        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.centerYAnchor)
        ])

        tableView.backgroundView = backgroundView
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
                self?.renderDataStateForPredictionItems(predictionItems)
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
        loadingIndicatorView.startAnimating()
    }

    private func renderDataStateForPredictionItems(_ predictionItems: [PredictionItem]) {
        loadingIndicatorView.stopAnimating()
        updateTableViewDataWithPredictionsItems(predictionItems)
    }

    private func renderEmptyDataStateForPredictions(_ predictionItems: [PredictionItem]) {
        loadingIndicatorView.stopAnimating()
        updateTableViewDataWithPredictionsItems(predictionItems)
    }

    private func renderErrorDataStateForMessage(_ message: String) {
        loadingIndicatorView.stopAnimating()
        presentAlertViewControllerWithTitle("An Error Occured", message: message)
    }

    // MARK: - TableView Updating

    private func updateTableViewDataWithPredictionsItems(_ predictionItems: [PredictionItem]) {
        tableView.update(oldData: self.predictionItems, newData: predictionItems) { newPredictionItems in
            self.predictionItems = newPredictionItems
        }
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictionItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = predictionItems[indexPath.row]

        switch item {
        case .prediction(let prediction):
            return predictionCellForPrediction(prediction, indexPath: indexPath)
        case .emptyPrediction:
            return simpleMessageCellForIndexPath(indexPath)
        }
    }

    // MARK: - Table View Cells

    // Prediction Cell
    private func predictionCellForPrediction(_ prediction: Prediction, indexPath: IndexPath) -> PredictionCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PredictionCell.ReuseId,
                                                       for: indexPath) as? PredictionCell else {
            fatalError("PredictionsViewController Error: Unable to dequeue PredictionCell at index path \(indexPath)")
        }
        cell.configureWithPrediction(prediction, dividerVisible: predictionItems.lastIndex != indexPath.row)
        return cell
    }

    // Empty Favorite Stop Cell
    private func simpleMessageCellForIndexPath(_ indexPath: IndexPath) -> SimpleMessageCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SimpleMessageCell.ReuseId,
                                                       for: indexPath) as? SimpleMessageCell else {
            fatalError("PredictionsViewController Error: Unable to dequeue SimpleMessageCell at index path \(indexPath)")
        }
        cell.configureWithMessage("No upcoming arrival times")
        return cell
    }
}
