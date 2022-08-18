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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Bus Watch"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode =  .always
    }

    // MARK: - Setup

    private func setupViewController() {
        navigationItem.backButtonDisplayMode = .minimal
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(OverviewTitleHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: OverviewTitleHeaderView.reuseId)
        tableView.register(OverviewFavoriteStopCell.self, forCellReuseIdentifier: OverviewFavoriteStopCell.reuseId)
        tableView.register(OverviewMessageCell.self, forCellReuseIdentifier: OverviewMessageCell.reuseId)
        tableView.register(OverviewMapCell.self, forCellReuseIdentifier: OverviewMapCell.reuseId)

        // Preload map cell
        _ = tableView.dequeueReusableCell(withIdentifier: OverviewMapCell.reuseId, for: IndexPath(row: 0, section: 1))
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
        presentAlertViewControllerWithTitle("An Error Occurred", message: message)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]

        switch item {
        case .favoriteStop(let favoriteStop):
            self.viewModel.handleIntent(.favoriteStopSelected(favoriteStop))
        case .map:
            self.viewModel.handleIntent(.stopMapSelected)
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
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OverviewTitleHeaderView.reuseId)
            as? OverviewTitleHeaderView
        header?.configureWithTitle(sections[section].title)
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
    private func favoriteStopCellForStop(_ favoriteStop: FavoriteStop,
                                         indexPath: IndexPath) -> OverviewFavoriteStopCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: OverviewFavoriteStopCell.reuseId,
                                                       for: indexPath) as? OverviewFavoriteStopCell else {
            fatalError("""
                       OverviewViewController Error: Unable to dequeue OverviewFavoriteStopCell at index
                       path \(indexPath)
                       """)
        }

        let dividerVisible = sections[indexPath.section].items.lastIndex != indexPath.row
        cell.configureWithStop(favoriteStop, dividerVisible: dividerVisible)
        return cell
    }

    // Empty Favorite Stop Cell
    private func simpleMessageCellForIndexPath(_ indexPath: IndexPath) -> OverviewMessageCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: OverviewMessageCell.reuseId,
                                                       for: indexPath) as? OverviewMessageCell else {
            fatalError("OverviewViewController Error: Unable to dequeue OverviewMessageCell at index path \(indexPath)")
        }

        cell.configureWithMessage("No favorite stops found")
        return cell
    }

    // Map Cell
    private func mapCellForLocationBounds(_ locationBounds: LocationBounds,
                                          indexPath: IndexPath) -> OverviewMapCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: OverviewMapCell.reuseId,
                                                       for: indexPath) as? OverviewMapCell else {
            fatalError("OverviewViewController Error: Unable to dequeue OverviewMapCell at index path \(indexPath)")
        }

        cell.configureWithLocationBounds(locationBounds)
        return cell
    }
}
