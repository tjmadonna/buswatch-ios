//
//  OverviewViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/14/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit
import Combine

final class OverviewViewController: UITableViewController {

    // MARK: - Properties

    private let viewModel: OverviewViewModel

    private var sections = [OverviewSection]()

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(viewModel: OverviewViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("OverviewViewController Error: View Controller cannot be initialized with init(coder:)")
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupTableView()
        setupObservers()
    }

    // MARK: - Setup

    private func setupViewController() {
        title = "Bus Watch"
        view.backgroundColor = Colors.backgroundColor
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(OverviewTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: OverviewTitleHeaderView.ReuseId)
        tableView.register(FavoriteStopCell.self, forCellReuseIdentifier: FavoriteStopCell.ReuseId)
        tableView.register(SimpleMessageCell.self, forCellReuseIdentifier: SimpleMessageCell.ReuseId)
        tableView.register(MapCell.self, forCellReuseIdentifier: MapCell.ReuseId)

        // Preload map cell
        _ = tableView.dequeueReusableCell(withIdentifier: MapCell.ReuseId, for: IndexPath(row: 0, section: 1))
    }

    private func setupObservers() {
        viewModel.state.sink { [weak self] state in
            switch state {
            case .loading:
                break
            case .data(let sections):
                self?.renderDataStateForSections(sections)
            case .error(let message):
                self?.renderErrorStateWithMessage(message)
            }
        }.store(in: &cancellables)
    }

    // MARK: - State Rendering

    private func renderDataStateForSections(_ sections: [OverviewSection]) {
        self.sections = sections
        self.tableView.reloadData()
    }

    private func renderErrorStateWithMessage(_ message: String) {
        // TODO: Handle error
    }

        // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]

        switch item {
        case .favoriteStop(let stop):
            self.viewModel.handlePresentPredictionsViewControllerForStop(stop)
        case .map(_):
            self.viewModel.handlePresentStopMapViewController()
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OverviewTitleHeaderView.ReuseId) as? OverviewTitleHeaderView
        header?.title = sections[section].title
        return header
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]

        switch item {
        case .favoriteStop(let stop):
            return favoriteStopCellForStop(stop, indexPath: indexPath)
        case .emptyFavoriteStop:
            return simpleMessageCellForIndexPath(indexPath)
        case .map(let locationBounds):
            return mapCellForLocationBounds(locationBounds, indexPath: indexPath)
        }
    }

    // MARK: - Table View Cells

    // Favorite Stop Cell
    private func favoriteStopCellForStop(_ stop: Stop, indexPath: IndexPath) -> FavoriteStopCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteStopCell.ReuseId,
                                                       for: indexPath) as? FavoriteStopCell else {
            fatalError("OverviewViewController Error: Unable to dequeue FavoriteStopCell at index path \(indexPath)")
        }
        cell.configureWithStop(stop, dividerVisible: sections[indexPath.section].items.lastIndex != indexPath.row)
        return cell
    }

    // Empty Favorite Stop Cell
    private func simpleMessageCellForIndexPath(_ indexPath: IndexPath) -> SimpleMessageCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SimpleMessageCell.ReuseId,
                                                       for: indexPath) as? SimpleMessageCell else {
            fatalError("OverviewViewController Error: Unable to dequeue SimpleMessageCell at index path \(indexPath)")
        }
        cell.configureWithMessage("No favorite stops found")
        return cell
    }

    // Map Cell
    private func mapCellForLocationBounds(_ locationBounds: LocationBounds, indexPath: IndexPath) -> MapCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MapCell.ReuseId,
                                                       for: indexPath) as? MapCell else {
            fatalError("OverviewViewController Error: Unable to dequeue MapCell at index path \(indexPath)")
        }
        cell.configureWithLocationBounds(locationBounds)
        return cell
    }
}
