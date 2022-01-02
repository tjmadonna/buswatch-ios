//
//  FilterRoutesViewController.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit
import Combine

public final class FilterRoutesViewController : UITableViewController {

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

    private var routes = [PresentationRoute]()

    private let viewModel: FilterRoutesViewModel

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    public init(viewModel: FilterRoutesViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("FilterRoutesViewController Error: View Controller cannot be initialized with init(coder:)")
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

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterRoutesViewController.cellReuseId, for: indexPath)
        let route = routes[indexPath.row]
        configureCell(cell, forRoute: route)
        return cell
    }

    // MARK: - UITableViewDelegate

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let intent = FilterRoutesIntent.routeSelected(indexPath.item)
        viewModel.handleIntent(intent)
    }

    // MARK: - Table View Cells

    private func configureCell(_ cell: UITableViewCell?, forRoute route: PresentationRoute) {
        cell?.textLabel?.text = route.routeId
        cell?.selectionStyle = .none;
        if route.selected {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
    }

    // MARK: - Render

    private func renderDataStateForRoutes(_ routes: [PresentationRoute]) {
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
