//
//  PredictionsDataViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/22/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit

final class PredictionsDataViewController: UITableViewController {

    // MARK: - Properties

    private var predictions = [Prediction]()

    // MARK: - Initialization

    init() {
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("PredictionsDataViewController Error: View Controller cannot be initialized with init(coder:)")
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
        tableView.register(PredictionsCell.self, forCellReuseIdentifier: PredictionsCell.reuseId)
        tableView.register(PredictionsMessageCell.self, forCellReuseIdentifier: PredictionsMessageCell.reuseId)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PredictionsCell.reuseId, for: indexPath)
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // MARK: - Table View Cells

    private func configureCell(_ cell: UITableViewCell?, forIndexPath indexPath: IndexPath) {
        guard let cell = cell as? PredictionsCell else {
            fatalError("""
                       PredictionsViewController Error: Unable to dequeue PredictionsPredictionCell at index
                       path \(indexPath))
                       """)
        }
        let prediction = predictions[indexPath.row]
        cell.selectionStyle = .none
        cell.configureWithPrediction(prediction, dividerVisible: indexPath.row != predictions.lastIndex, animate: false)
    }

    // MARK: - Helper methods

    func updatePredictions(_ predictions: [Prediction], animate: Bool) {
        if animate {
            tableView.update(oldData: self.predictions, newData: predictions, with: .fade, setData: { newData in
                self.predictions = newData
            }, reloadRow: { indexPath in
                let cell = self.tableView.cellForRow(at: indexPath)
                configureCell(cell, forIndexPath: indexPath)
            })
        } else {
            self.predictions = predictions
            tableView.reloadData()
        }
    }
}
