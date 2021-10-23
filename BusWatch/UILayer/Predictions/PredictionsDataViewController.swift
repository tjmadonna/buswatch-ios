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

    private var predictionItems = [PredictionItem]()

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
        view.backgroundColor = Colors.backgroundColor
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(PredictionCell.self, forCellReuseIdentifier: PredictionCell.ReuseId)
        tableView.register(SimpleMessageCell.self, forCellReuseIdentifier: SimpleMessageCell.ReuseId)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictionItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = predictionItems[indexPath.row]

        switch item {
        case .prediction(let prediction):
            return predictionCellForPrediction(prediction, indexPath: indexPath)
        case .emptyPrediction:
            return simpleMessageCellForIndexPath(indexPath)
        }
    }

    // MARK: - Table View Cells

    // Prediction Cell
    private func predictionCellForPrediction(_ prediction: Prediction, indexPath: IndexPath) -> PredictionCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PredictionCell.ReuseId,
                                                       for: indexPath) as? PredictionCell else {
            fatalError("PredictionsViewController Error: Unable to dequeue PredictionCell at index path \(indexPath)")
        }
        cell.configureWithPrediction(prediction, dividerVisible: predictionItems.lastIndex != indexPath.row)
        return cell
    }

    // Empty Favorite Stop Cell
    private func simpleMessageCellForIndexPath(_ indexPath: IndexPath) -> SimpleMessageCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SimpleMessageCell.ReuseId,
                                                       for: indexPath) as? SimpleMessageCell else {
            fatalError("PredictionsViewController Error: Unable to dequeue SimpleMessageCell at index path \(indexPath)")
        }
        cell.configureWithMessage("No upcoming arrival times")
        return cell
    }

    // MARK: - Public methods

    func updatePredictions(_ predictionItems: [PredictionItem], animate: Bool) {
        if animate {
            tableView.update(oldData: self.predictionItems, newData: predictionItems) { newPredictionItems in
                self.predictionItems = newPredictionItems
            }
        } else {
            self.predictionItems = predictionItems
            tableView.reloadData()
        }
    }
}
