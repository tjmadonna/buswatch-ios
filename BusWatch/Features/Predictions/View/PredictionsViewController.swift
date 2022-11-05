//
//  PredictionsViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/27/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import DifferenceKit
import Foundation
import UIKit

final class PredictionsViewController: UIViewController {

    // MARK: - Views
    private let loadingView: LoadingStripView = {
        let view = LoadingStripView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(SectionMessageCell.self, forCellReuseIdentifier: SectionMessageCell.reuseId)
        tableView.register(PredictionsCell.self, forCellReuseIdentifier: PredictionsCell.reuseId)
        return tableView
    }()

    private let titleView: SectionHeaderView = {
        let view = SectionHeaderView(reuseIdentifier: SectionHeaderView.reuseId)
        return view
    }()

    private let footerView: SectionFooterView = {
        let view = SectionFooterView(reuseIdentifier: SectionFooterView.reuseId)
        return view
    }()

    private lazy var favoriteUIBarButtonItem: UIBarButtonItem = {
        let image = UIImage(systemName: "star")
        return UIBarButtonItem(image: image,
                               style: .plain,
                               target: self,
                               action: #selector(handleFavoriteBarButtonItemTouch(sender:)))
    }()

    // MARK: - Properties
    private let viewModel: PredictionsViewModel

    private var cancellables: [AnyCancellable] = []

    private var dataState: [AnyDifferentiable] = [.init(PredictionsMessageDataItem(message: "Loading..."))]

    // MARK: - Initialization
    init(viewModel: PredictionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("View Controller cannot be initialized with init(coder:)")
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
        navigationItem.title = "Arrival Times"
        navigationItem.largeTitleDisplayMode =  .never
    }

}

// MARK: - Setup
extension PredictionsViewController {

    private func setupViewController() {
        navigationItem.backButtonDisplayMode = .minimal
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 4),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupBarItems() {
        let filterImage = UIImage(systemName: "line.3.horizontal.decrease.circle")
        let filterRouteBarButtonItem = UIBarButtonItem(image: filterImage,
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(handleFilterRoutesBarButtonItemTouch(sender:)))
        navigationItem.rightBarButtonItems = [filterRouteBarButtonItem, favoriteUIBarButtonItem]
    }

    private func setupObservers() {
        viewModel.titleState
            .sink { [weak self] newTitle in
                self?.titleView.configureWithTitle(newTitle)
            }
            .store(in: &cancellables)

        viewModel.favoriteState
            .sink { [weak self] favorite in
                let imageName = favorite ? "star.fill" : "star"
                self?.favoriteUIBarButtonItem.image = UIImage(systemName: imageName)
            }
            .store(in: &cancellables)

        viewModel.loadingState
            .sink { [weak self] loading in
                if loading {
                    self?.loadingView.startAnimating()
                } else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.dataState
            .sink { [weak self] newDataState in
                let diffs = newDataState.map { AnyDifferentiable($0) }
                self?.renderDataState(diffs)
            }
            .store(in: &cancellables)

        viewModel.lastUpdated
            .sink { [weak self] lastUpdated in
                guard let lastUpdated = lastUpdated else { return }
                self?.renderLastUpdatedState(lastUpdated)
            }
            .store(in: &cancellables)
    }

}

// MARK: - UITableViewDataSource
extension PredictionsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataState.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataState[indexPath.row].base
        if item is PredictionsPredictionDataItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: PredictionsCell.reuseId, for: indexPath)
            configurePredictionsCell(cell, forIndexPath: indexPath, animate: false)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: SectionMessageCell.reuseId, for: indexPath)
        if item is PredictionsMessageDataItem {
            configureMessageCell(cell, forIndexPath: indexPath, animate: false)
        }
        return cell
    }

}

// MARK: - UITableViewDelegate
extension PredictionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 96
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return titleView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

// MARK: - View Updating
extension PredictionsViewController {

    private func configurePredictionsCell(_ cell: UITableViewCell?, forIndexPath indexPath: IndexPath, animate: Bool) {
        guard let cell = cell as? PredictionsCell else {
            fatalError("Unable to dequeue PredictionsCell at index path \(indexPath))")
        }
        guard let prediction = dataState[indexPath.row].base as? PredictionsPredictionDataItem else {
            fatalError("Data item is not of type PredictionsPredictionDataItem")
        }
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.configureWithPrediction(prediction, dividerVisible: indexPath.row != dataState.lastIndex, animate: animate)
    }

    private func configureMessageCell(_ cell: UITableViewCell?, forIndexPath indexPath: IndexPath, animate: Bool) {
        guard let cell = cell as? SectionMessageCell else {
            fatalError("Unable to dequeue SectionMessageCell at index path \(indexPath))")
        }
        guard let item = dataState[indexPath.row].base as? PredictionsMessageDataItem else {
            fatalError("Data item is not of type PredictionsMessageDataItem")
        }
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.configureWithMessage(item.message, animate: animate)
    }

    private func renderDataState(_ newDataState: [AnyDifferentiable]) {
        let stagedChangeset = StagedChangeset(source: self.dataState, target: newDataState)
        tableView.reload(using: stagedChangeset, with: .fade, setData: { [weak self] newState in
            self?.dataState = newState
        }, reloadRow: { indexPath in
            // Cell will return nil if cell if off screen. We don't need to update it then
            let cell = self.tableView.cellForRow(at: indexPath)
            if let cell = cell as? PredictionsCell {
                configurePredictionsCell(cell, forIndexPath: indexPath, animate: true)
            }
            if let cell = cell as? SectionMessageCell {
                configureMessageCell(cell, forIndexPath: indexPath, animate: true)
            }
        })
    }

    private func renderLastUpdatedState(_ lastUpdated: Date) {
        let lastUpdatedSecs = Int(-1 * lastUpdated.timeIntervalSinceNow)
        switch lastUpdatedSecs {
        case Int.min..<30:
            footerView.configureWithMessage("Last Updated: Just Now")
        case 30..<60:
            footerView.configureWithMessage("Last Updated: 30 seconds ago")
        case 60..<120:
            footerView.configureWithMessage("Last Updated: 1 minute ago")
        default:
            footerView.configureWithMessage("Last Updated: \(Int(lastUpdatedSecs / 60)) minutes ago")
        }
    }
    
}

// MARK: - Selectors
extension PredictionsViewController {

    @objc private func handleFavoriteBarButtonItemTouch(sender: Any) {
        viewModel.handleIntent(.toggleFavorited)
    }

    @objc private func handleFilterRoutesBarButtonItemTouch(sender: Any) {
        viewModel.handleIntent(.filterRoutesSelected)
    }

}
