//
//  PredictionsMessageCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/3/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit

final class PredictionsMessageCell: UITableViewCell {

    static let reuseId = "PredictionsMessageCell"

    // MARK: - Subviews

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("PredictionsMessageCell Error: Table View Cell cannot be initialized with init(coder:)")
    }

    // MARK: - Setup

    private func setupSubviews() {
        contentView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - properties/functions

    func configureWithMessage(_ message: String) {
        messageLabel.text = message
    }
}
