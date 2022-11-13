//
//  SectionFooterView.swift
//  BusWatch
//
//  Created by Tyler Madonna on 9/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import UIKit

final class SectionFooterView: UITableViewHeaderFooterView {

    static let reuseId = "SectionFooterView"

    // MARK: - Views

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .opaqueSeparator
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    // MARK: - Initialization

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) cannot be used to create view")
    }

}

extension SectionFooterView {

    private func setup() {
        style()
        layout()
    }

    private func style() {
        contentView.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.secondarySystemBackground
            default:
                return UIColor.systemBackground
            }
        }
    }

    private func layout() {
        contentView.addSubview(dividerView)
        contentView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

}

// MARK: - Public functions
extension SectionFooterView {

    func configureWithMessage(_ message: String) {
        if self.messageLabel.text != message {
            animateTextChange(message, view: self.messageLabel)
        }
    }

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
