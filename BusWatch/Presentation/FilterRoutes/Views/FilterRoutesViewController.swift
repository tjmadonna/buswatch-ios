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

    private var routes = [FilterableRoute]()

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(viewModel: FilterRoutesViewModel) {
        self.viewModel = viewModel
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
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        tableView.register(FilterRouteCell.self, forCellReuseIdentifier: FilterRouteCell.reuseId)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterRouteCell.reuseId, for: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let intent = FilterRoutesIntent.routeSelected(indexPath.item)
        viewModel.handleIntent(intent)
    }

    // MARK: - Table View Cells

    private func configureCell(_ cell: UITableViewCell?, forIndexPath indexPath: IndexPath) {
        guard let cell = cell as? FilterRouteCell else {
            fatalError("""
                       FilterRoutesViewController Error: Unable to dequeue FilterRouteCell at index path \(indexPath))
                       """)
        }
        let route = routes[indexPath.row]
        cell.selectionStyle = .none
        cell.configureWithFilterableRoute(route, dividerVisible: indexPath.row != routes.lastIndex)
    }

    // MARK: - Render

    private func renderDataStateForRoutes(_ routes: [FilterableRoute]) {
        if self.routes.isEmpty {
            self.routes = routes
            tableView.reloadData()
        } else {
            tableView.update(oldData: self.routes, newData: routes, with: .fade, setData: { newData in
                self.routes = newData
            }, reloadRow: { indexPath in
                let cell = self.tableView.cellForRow(at: indexPath)
                self.configureCell(cell, forIndexPath: indexPath)
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
