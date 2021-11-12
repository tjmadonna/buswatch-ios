//
//  OverviewTitleHeaderView.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/18/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

struct OverviewTitleHeaderViewStyle {

    let backgroundColor: UIColor

}

final class OverviewTitleHeaderView: UITableViewHeaderFooterView {

    static let ReuseId = "OverviewTitleHeaderView"

    // MARK: - Views

    private let textBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        return label
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .opaqueSeparator
        return view
    }()

    // MARK: - Initialization

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("OverviewTitleHeaderView Error: Collection View Cell cannot be initialized with init(coder:)")
    }

    // MARK: - Setup

    private func setupSubviews() {
        contentView.addSubview(textBackgroundView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dividerView)

        NSLayoutConstraint.activate([
            textBackgroundView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            textBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 0.75),
            dividerView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
    }

    // MARK: - Public properties/functions

    func configureWithTitle(_ title: String, style: OverviewTitleHeaderViewStyle) {
        textBackgroundView.backgroundColor = style.backgroundColor
        titleLabel.text = title
    }
}
