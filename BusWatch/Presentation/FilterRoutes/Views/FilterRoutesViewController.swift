//
//  FilterRoutesViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit
import Combine

final class FilterRoutesViewController: UITableViewController {

    private static let cellReuseId = "UITableViewCell"

    // MARK: - Views

    private lazy var cancelBarButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .cancel,
                               target: self,
                               action: #selector(handleCancelTouch))
    }()

    private lazy var saveBarButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save,
                               target: self,
                               action: #selector(handleSaveTouch))
    }()

    // MARK: - Properties

    private let viewModel: FilterRoutesViewModel

    private let style: FilterRoutesStyle

    private var routes = [ExclusionRoute]()

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(viewModel: FilterRoutesViewModel, style: FilterRoutesStyle) {
        self.viewModel = viewModel
        self.style = style
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("FilterRoutesViewController Error: View Controller cannot be initialized with init(coder:)")
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
        title = "Filter Routes"

        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = saveBarButton
    }

    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FilterRoutesViewController.cellReuseId)
    }

    private func setupObservers() {
        viewModel.state.sink { [weak self] state in
            switch state {
            case .loading:
                break
            case .data(let routeItems):
                self?.renderDataStateForRoutes(routeItems)
            case .error(let message):
                self?.renderErrorDataStateForMessage(message)
            }
        }
        .store(in: &cancellables)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterRoutesViewController.cellReuseId, for: indexPath)
        let route = routes[indexPath.row]
        configureCell(cell, forRoute: route)
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let intent = FilterRoutesIntent.routeSelected(indexPath.item)
        viewModel.handleIntent(intent)
    }

    // MARK: - Table View Cells

    private func configureCell(_ cell: UITableViewCell?, forRoute route: ExclusionRoute) {
        cell?.textLabel?.text = route.id
        cell?.selectionStyle = .none
        cell?.tintColor = style.checkColor
        if route.excluded {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
    }

    // MARK: - Render

    private func renderDataStateForRoutes(_ routes: [ExclusionRoute]) {
        if self.routes.isEmpty {
            self.routes = routes
            tableView.reloadData()
        } else {
            tableView.update(oldData: self.routes, newData: routes, with: .fade, setData: { newData in
                self.routes = newData
            }, reloadRow: { indexPath in
                let cell = self.tableView.cellForRow(at: indexPath)
                let route = self.routes[indexPath.row]
                self.configureCell(cell, forRoute: route)
            })
        }
    }

    private func renderErrorDataStateForMessage(_ message: String) {
//        presentAlertViewControllerWithTitle("An Error Occured", message: message)
        print(message)
    }

    // MARK: - Button handling

    @objc private func handleCancelTouch() {
        viewModel.handleIntent(.cancelSelected)
    }

    @objc private func handleSaveTouch() {
        viewModel.handleIntent(.saveSelected)
    }
}
