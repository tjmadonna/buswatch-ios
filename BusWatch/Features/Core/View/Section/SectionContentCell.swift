//
//  SectionContentCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 9/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import UIKit

final class SectionContentCell: UITableViewCell {

    // MARK: - Properties

    static let reuseId = "SectionContentCell"

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
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) cannot be used to create view")
    }

}

extension SectionContentCell {

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

        contentView.addSubview(decoratorContainerView)
        contentView.addSubview(textStackView)
        contentView.addSubview(dividerView)

        NSLayoutConstraint.activate([
            decoratorContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            decoratorContainerView.widthAnchor.constraint(equalToConstant: 60),
            decoratorContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            decoratorContainerView.heightAnchor.constraint(equalToConstant: 60),
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

}

// MARK: - Public functions
extension SectionContentCell {

    func configureWithStop(_ favoriteStop: FavoriteStop, dividerVisible: Bool) {
        dividerView.isHidden = !dividerVisible

        decoratorLabel.text = favoriteStop.title.first?.description
        titleLabel.text = favoriteStop.title
        routesLabel.text = favoriteStop.filteredRoutes.joined(separator: ", ")
    }

}
