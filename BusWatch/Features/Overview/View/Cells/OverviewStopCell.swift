//
//  OverviewStopCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 9/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

final class OverviewStopCell: UITableViewCell {

    // MARK: - Properties

    static let reuseId = "OverviewStopCell"

    // MARK: - Subviews

    private let decoratorContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Resources.Colors.appGold
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "E7E7E7")?.cgColor
        return view
    }()

    private let decoratorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, routesLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()

    private let routesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [decoratorContainerView, textStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) cannot be used to create view")
    }

}

// MARK: - Setup
extension OverviewStopCell {

    private func setup() {
        style()
        layout()
    }

    private func style() {
        accessoryType = .disclosureIndicator
    }

    private func layout() {
        decoratorContainerView.addSubview(decoratorLabel)

        NSLayoutConstraint.activate([
            decoratorLabel.centerXAnchor.constraint(equalTo: decoratorContainerView.centerXAnchor),
            decoratorLabel.centerYAnchor.constraint(equalTo: decoratorContainerView.centerYAnchor)
        ])

        contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: textStackView.widthAnchor),
            routesLabel.widthAnchor.constraint(equalTo: textStackView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        NSLayoutConstraint.activate([
            decoratorContainerView.widthAnchor.constraint(equalToConstant: 60),
            decoratorContainerView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

}

// MARK: - Public functions
extension OverviewStopCell {

    func configureWithStop(_ favoriteStop: OverviewFavoriteStop) {
        decoratorLabel.text = favoriteStop.title.first?.description
        titleLabel.text = favoriteStop.title
        routesLabel.text = favoriteStop.routes.joined(separator: ", ")
    }

}
