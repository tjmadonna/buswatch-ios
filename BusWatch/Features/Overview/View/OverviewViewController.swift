//
//  OverviewViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/14/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import MapKit
import UIKit

final class OverviewViewController: UITableViewController {

    // MARK: - Views
    private let mapCell: OverviewMapCell = {
        return OverviewMapCell(style: .default, reuseIdentifier: nil)
    }()

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
        fatalError("View Controller cannot be initialized with init(coder:)")
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
        refreshNavigationItems()
    }

}

// MARK: - Setup
extension OverviewViewController {

    private func setupViewController() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(handleSettingsBarButtonItemTouch(sender:)))
    }

    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseId)
        tableView.register(SectionFooterView.self, forHeaderFooterViewReuseIdentifier: SectionFooterView.reuseId)
        tableView.register(SectionMessageCell.self, forCellReuseIdentifier: SectionMessageCell.reuseId)
        tableView.register(OverviewStopCell.self, forCellReuseIdentifier: OverviewStopCell.reuseId)
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

    private func refreshNavigationItems() {
        navigationItem.title = "Bus Watch"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode =  .always
    }

}

// MARK: - State Rendering
extension OverviewViewController {

    private func renderDataStateForSections(_ sections: [OverviewSection]) {
        self.sections = sections
        self.tableView.reloadData()
    }

    private func renderErrorStateWithMessage(_ message: String) {
        presentAlertViewControllerWithTitle("An Error Occurred", message: message)
    }

}

// MARK: - UITableViewDelegate
extension OverviewViewController {

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
        return 96
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.reuseId) as? SectionHeaderView
        header?.configureWithTitle(sections[section].title)
        return header
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionFooterView.reuseId)
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

// MARK: - UITableViewDataSource
extension OverviewViewController {

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
        case .map(let coordinateRegion):
            return mapCellForCoordinateRegion(coordinateRegion, indexPath: indexPath)
        }
    }

}

// MARK: - Table View Cells
extension OverviewViewController {

    // Favorite Stop Cell
    private func favoriteStopCellForStop(_ favoriteStop: OverviewFavoriteStop, indexPath: IndexPath) -> OverviewStopCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: OverviewStopCell.reuseId,
                                                       for: indexPath) as? OverviewStopCell else {
            fatalError("Unable to dequeue OverviewStopCell at index path \(indexPath)")
        }
        cell.configureWithStop(favoriteStop)
        return cell
    }

    // Empty Favorite Stop Cell
    private func simpleMessageCellForIndexPath(_ indexPath: IndexPath) -> SectionMessageCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionMessageCell.reuseId,
                                                       for: indexPath) as? SectionMessageCell else {
            fatalError("Unable to dequeue SectionMessageCell at index path \(indexPath)")
        }
        cell.configureWithMessage("No favorite stops found")
        return cell
    }

    // Map Cell
    private func mapCellForCoordinateRegion(_ coordinateRegion: MKCoordinateRegion, indexPath: IndexPath) -> OverviewMapCell {
        let cell = mapCell
        cell.configureWithCoordinateRegion(coordinateRegion)
        return cell
    }

}


// MARK: - Selectors
extension OverviewViewController {

    @objc private func handleSettingsBarButtonItemTouch(sender: Any) {
        viewModel.handleIntent(.settingsSelected)
    }

}
