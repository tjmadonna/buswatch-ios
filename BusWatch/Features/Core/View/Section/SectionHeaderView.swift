//
//  SectionHeaderView.swift
//  BusWatch
//
//  Created by Tyler Madonna on 9/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import UIKit

final class SectionHeaderView: UITableViewHeaderFooterView {

    static let reuseId = "SectionHeaderView"

    // MARK: - Views

    private let textBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.secondarySystemBackground
            default:
                return UIColor.systemBackground
            }
        }
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
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) cannot be used to create view")
    }

}

extension SectionHeaderView {

    private func setup() {
        style()
        layout()
    }

    private func style() {

    }

    private func layout() {
        contentView.addSubview(textBackgroundView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dividerView)

        NSLayoutConstraint.activate([
            textBackgroundView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -16),
            textBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
    }

}

// MARK: - Public functions
extension SectionHeaderView {

    func configureWithTitle(_ title: String) {
        titleLabel.text = title
    }

}
