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

        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 0.75),
            dividerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
    }

}

