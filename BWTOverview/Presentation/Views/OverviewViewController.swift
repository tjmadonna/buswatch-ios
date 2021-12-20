//
//  OverviewViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/14/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit
import Combine

public final class OverviewViewController: UITableViewController {

    // MARK: - Properties

    private let titleView: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Bus Watch"
        label.textColor = .white
        return label
    }()

    private let viewModel: OverviewViewModel

    private let style: OverviewStyleRepresentable

    private var sections = [OverviewSection]()

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    public init(viewModel: OverviewViewModel, style: OverviewStyleRepresentable) {
        self.viewModel = viewModel
        self.style = style
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("OverviewViewController Error: View Controller cannot be initialized with init(coder:)")
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - UIViewController Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupTableView()
        setupObservers()
    }

    // MARK: - Setup

    private func setupViewController() {
        title = ""
        navigationItem.titleView = titleView
        view.backgroundColor = style.backgroundColor
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(OverviewTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: OverviewTitleHeaderView.ReuseId)
        tableView.register(FavoriteStopCell.self, forCellReuseIdentifier: FavoriteStopCell.reuseId)
        tableView.register(SimpleMessageCell.self, forCellReuseIdentifier: SimpleMessageCell.reuseId)
        tableView.register(MapCell.self, forCellReuseIdentifier: MapCell.reuseId)

        // Preload map cell
        _ = tableView.dequeueReusableCell(withIdentifier: MapCell.reuseId, for: IndexPath(row: 0, section: 1))
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

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]

        switch item {
        case .favoriteStop(let favoriteStop):
            self.viewModel.handleIntent(.favoriteStopSelected(favoriteStop))
        case .map(_):
            self.viewModel.handleIntent(.stopMapSelected)
        default:
            break
        }
    }

    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }

    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OverviewTitleHeaderView.ReuseId) as? OverviewTitleHeaderView
        header?.configureWithTitle(sections[section].title,
                                   style: OverviewTitleHeaderViewStyle(backgroundColor: style.cellBackground))
        return header
    }

    public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // MARK: - UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    private func favoriteStopCellForStop(_ favoriteStop: FavoriteStop, indexPath: IndexPath) -> FavoriteStopCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteStopCell.reuseId,
                                                       for: indexPath) as? FavoriteStopCell else {
            fatalError("OverviewViewController Error: Unable to dequeue FavoriteStopCell at index path \(indexPath)")
        }
        let style = FavoriteStopCellStyle(dividerVisible: sections[indexPath.section].items.lastIndex != indexPath.row,
                                          backgroundColor: style.cellBackground,
                                          decoratorColor: style.cellDecoratorColor,
                                          decoratorTextColor: style.cellDecoratorTextColor)
        cell.configureWithStop(favoriteStop, style: style)
        return cell
    }

    // Empty Favorite Stop Cell
    private func simpleMessageCellForIndexPath(_ indexPath: IndexPath) -> SimpleMessageCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SimpleMessageCell.reuseId,
                                                       for: indexPath) as? SimpleMessageCell else {
            fatalError("OverviewViewController Error: Unable to dequeue SimpleMessageCell at index path \(indexPath)")
        }
        let style = SimpleMessageCellStyle(backgroundColor: style.cellBackground)
        cell.configureWithMessage("No favorite stops found", style: style)
        return cell
    }

    // Map Cell
    private func mapCellForLocationBounds(_ locationBounds: LocationBounds, indexPath: IndexPath) -> MapCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MapCell.reuseId,
                                                       for: indexPath) as? MapCell else {
            fatalError("OverviewViewController Error: Unable to dequeue MapCell at index path \(indexPath)")
        }
        let style = MapCellStyle(backgroundColor: style.cellBackground)
        cell.configureWithLocationBounds(locationBounds, style: style)
        return cell
    }
}
