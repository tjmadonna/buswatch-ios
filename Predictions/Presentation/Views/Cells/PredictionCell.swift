//
//  PredictionCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

struct PredictionCellStyle {

    let dividerVisible: Bool

    let backgroundColor: UIColor

    let decoratorColor: UIColor

    let decoratorTextColor: UIColor

}

final class PredictionCell: UITableViewCell {

    static let reuseId = "PredictionCell"

    // MARK: - Subviews

    private let decoratorContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()

    private let decoratorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 35)
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, arrivalTimeLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
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

    private let capacityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let arrivalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
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
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("PredictionCell Error: Table View Cell cannot be initialized with init(coder:)")
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
        contentView.addSubview(capacityImageView)
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
            capacityImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            capacityImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            capacityImageView.widthAnchor.constraint(equalToConstant: 35),
            capacityImageView.heightAnchor.constraint(equalTo: capacityImageView.widthAnchor, multiplier: 215/280.0)
        ])

        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: decoratorContainerView.trailingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(equalTo: capacityImageView.leadingAnchor, constant: -5),
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

    func configureWithStyle(_ style: PredictionCellStyle) {
        backgroundColor = style.backgroundColor
        decoratorContainerView.backgroundColor = style.decoratorColor
        decoratorLabel.textColor = style.decoratorTextColor
        dividerView.isHidden = !style.dividerVisible
    }

    func configureWithPrediction(_ prediction: PresentationPrediction, animate: Bool) {
        capacityImageView.isHidden = prediction.capacity == nil

        if animate {
            if decoratorLabel.text != prediction.route {
                animateTextChange(prediction.route, view: decoratorLabel)
            }

            if titleLabel.text != prediction.title {
                animateTextChange(prediction.title, view: titleLabel)
            }

            if capacityImageView.image != prediction.capacity {
                animateImageChange(prediction.capacity, view: capacityImageView)
            }

            if arrivalTimeLabel.text != prediction.arrivalMessage {
                animateTextChange(prediction.arrivalMessage, view: arrivalTimeLabel)
            }

        } else {
            decoratorLabel.text = prediction.route
            titleLabel.text = prediction.title
            capacityImageView.image = prediction.capacity
            arrivalTimeLabel.text = prediction.arrivalMessage
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

    private func animateImageChange(_ newImage: UIImage?, view: UIImageView) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            view.alpha = 0
        } completion: { _ in
            view.image = newImage
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
                view.alpha = 1
            }
        }
    }
}
