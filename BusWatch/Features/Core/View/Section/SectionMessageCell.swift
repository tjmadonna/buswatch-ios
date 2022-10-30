//
//  SectionMessageCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 9/25/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import UIKit

final class SectionMessageCell: UITableViewCell {

    static let reuseId = "SectionMessageCell"

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
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) cannot be used to create view")
    }

}

extension SectionMessageCell {

    private func setup() {
        style()
        layout()
    }

    private func style() {

    }

    private func layout() {
        contentView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

}

// MARK: - Public functions
extension SectionMessageCell {

    func configureWithMessage(_ message: String, animate: Bool = false) {
        if animate {
            animateTextChange(message, view: messageLabel)
        } else {
            messageLabel.text = message
        }
    }
    
}

extension SectionMessageCell {

    private func animateTextChange(_ newText: String?, view: UILabel) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            view.alpha = 0
        } completion: { _ in
            view.text = newText
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
                view.alpha = 1
            }
        }
    }

}
