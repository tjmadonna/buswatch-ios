//
//  FavoriteStopCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/16/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

final class FavoriteStopCell: UITableViewCell {

    static let ReuseId = "FavoriteStopCell"

    // MARK: - Subviews

    private let decoratorContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.backgroundColor = Colors.decoratorBackgroundColor
        return view
    }()

    private let decoratorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 35)
        label.textColor = Colors.decoratorTextBackgroundColor
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
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()

    private let routesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .opaqueSeparator
        return view
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Colors.raisedBackgroundColor
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("FavoriteStopCell Error: Table View Cell cannot be initialized with init(coder:)")
    }

    // MARK: - Setup

    private func setupSubviews() {
        decoratorContainerView.addSubview(decoratorLabel)

        NSLayoutConstraint.activate([
            decoratorLabel.centerXAnchor.constraint(equalTo: decoratorContainerView.centerXAnchor),
            decoratorLabel.centerYAnchor.constraint(equalTo: decoratorContainerView.centerYAnchor)
        ])

        contentView.addSubview(decoratorContainerView)
        contentView.addSubview(textStackView)
        contentView.addSubview(dividerView)

        NSLayoutConstraint.activate([
            decoratorContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            decoratorContainerView.widthAnchor.constraint(equalToConstant: 70),
            decoratorContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            decoratorContainerView.heightAnchor.constraint(equalToConstant: 70),
            decoratorContainerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10)
                .usingPriority(.defaultLow),
            decoratorContainerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
                .usingPriority(.defaultLow)
        ])

        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: decoratorContainerView.trailingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textStackView.centerYAnchor.constraint(equalTo: decoratorContainerView.centerYAnchor),
            textStackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10)
                .usingPriority(.defaultLow),
            textStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
                .usingPriority(.defaultLow)
        ])

        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 0.75),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerView.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    // MARK: - Public properties/functions

    func configureWithStop(_ stop: Stop, dividerVisible: Bool) {
        dividerView.isHidden = !dividerVisible

        decoratorLabel.text = stop.title.first?.description
        titleLabel.text = stop.title
        routesLabel.text = stop.routes.joined(separator: ", ")
    }
}
