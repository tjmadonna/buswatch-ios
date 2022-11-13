//
//  FilterRouteCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/28/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import UIKit

final class FilterRouteCell: UITableViewCell {

    static let reuseId = "FilterRouteCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()

    private let checkMarkImageView: UIImageView = {
        let image = UIImage(systemName: "checkmark")
        let imageView = UIImageView(image: image)
        imageView.tintColor = Resources.Colors.capacity
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("Table View Cell cannot be initialized with init(coder:)")
    }

    // MARK: - Setup

    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkMarkImageView)
        contentView.addSubview(dividerView)

        NSLayoutConstraint.activate([
            checkMarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkMarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            checkMarkImageView.heightAnchor.constraint(equalToConstant: 22),
            checkMarkImageView.widthAnchor.constraint(equalToConstant: 22)
        ])

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: checkMarkImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: checkMarkImageView.leadingAnchor, constant: -10)
        ])

        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configureWithFilterRoute(_ filterRoute: FilterRoute, dividerVisible: Bool) {
        titleLabel.text = filterRoute.id
        checkMarkImageView.isHidden = filterRoute.filtered

        dividerView.isHidden = !dividerVisible
    }

}
