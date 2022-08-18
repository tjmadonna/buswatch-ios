//
//  PredictionsNoDataViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/4/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit

final class PredictionsNoDataViewController: UITableViewController {

    // MARK: - Properties

    private var predictions: [Prediction]?

    // MARK: - Initialization

    init() {
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("PredictionsNoDataViewController Error: View Controller cannot be initialized with init(coder:)")
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupTableView()
    }

    // MARK: - Setup

    private func setupViewController() {

    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(PredictionsMessageCell.self, forCellReuseIdentifier: PredictionsMessageCell.reuseId)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PredictionsMessageCell.reuseId,
                                                       for: indexPath) as? PredictionsMessageCell else {
            fatalError("""
                       PredictionsNoDataViewController Error: Unable to dequeue PredictionsMessageCell at index
                       path \(indexPath)
                       """)
        }

        cell.configureWithMessage("No upcoming arrival times")
        return cell
    }
}
