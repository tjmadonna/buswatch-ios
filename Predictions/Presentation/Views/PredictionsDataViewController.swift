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

    private var predictions = [PresentationPrediction]()

    private let style: PredictionsStyleRepresentable

    // MARK: - Initialization

    init(style: PredictionsStyleRepresentable) {
        self.style = style
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
        view.backgroundColor = style.backgroundColor
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(PredictionCell.self, forCellReuseIdentifier: PredictionCell.reuseId)
        tableView.register(SimpleMessageCell.self, forCellReuseIdentifier: SimpleMessageCell.reuseId)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = predictions[indexPath.row]
        return predictionCellForPrediction(item, indexPath: indexPath)
    }

    // MARK: - Table View Cells

    // Prediction Cell
    private func predictionCellForPrediction(_ prediction: PresentationPrediction, indexPath: IndexPath) -> PredictionCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PredictionCell.reuseId,
                                                       for: indexPath) as? PredictionCell else {
            fatalError("PredictionsViewController Error: Unable to dequeue PredictionCell at index path \(indexPath)")
        }
        let cellStyle = PredictionCellStyle(dividerVisible: predictions.lastIndex != indexPath.row,
                                            backgroundColor: style.cellBackground,
                                            decoratorColor: style.cellDecoratorColor,
                                            decoratorTextColor: style.cellDecoratorTextColor)
        cell.configureWithStyle(cellStyle)
        cell.configureWithPrediction(prediction, animate: false)
        return cell
    }

    // MARK: - Public methods

    func updatePredictions(_ predictions: [PresentationPrediction], animate: Bool) {
        if animate {
            tableView.update(oldData: self.predictions, newData: predictions, with: .fade, setData: { newData in
                self.predictions = newData
            }, reloadRow: { indexPath in
                if let cell = self.tableView.cellForRow(at: indexPath) as? PredictionCell {
                    let prediction = self.predictions[indexPath.row]
                    cell.configureWithPrediction(prediction, animate: true)
                }
            })
        } else {
            self.predictions = predictions
            tableView.reloadData()
        }
    }
}
