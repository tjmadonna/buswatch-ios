//
//  PredictionsNoDataViewController.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/4/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit

final class PredictionsNoDataViewController: UITableViewController {

    // MARK: - Properties

    private var predictions: [PresentationPrediction]?

    private let style: PredictionsStyleRepresentable

    // MARK: - Initialization

    init(style: PredictionsStyleRepresentable) {
        self.style = style
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
        view.backgroundColor = style.backgroundColor
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(SimpleMessageCell.self, forCellReuseIdentifier: SimpleMessageCell.reuseId)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SimpleMessageCell.reuseId,
                                                       for: indexPath) as? SimpleMessageCell else {
            fatalError("PredictionsNoDataViewController Error: Unable to dequeue SimpleMessageCell at index path \(indexPath)")
        }
        let cellStyle = SimpleMessageCellStyle(backgroundColor: style.cellBackground)
        cell.configureWithMessage("No upcoming arrival times", style: cellStyle)
        return cell
    }
}
