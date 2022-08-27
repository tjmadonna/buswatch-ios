//
//  PredictionsCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

final class PredictionsCell: UITableViewCell {

    static let reuseId = "PredictionsCell"

    // MARK: - Subviews

    private let decoratorContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = Resources.Colors.appGold
        return view
    }()

    private let decoratorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
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

    private var capacityImageName: String?

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
            decoratorLabel.centerYAnchor.constraint(equalTo: decoratorContainerView.centerYAnchor),
            decoratorLabel.leadingAnchor.constraint(equalTo: decoratorContainerView.leadingAnchor, constant: 5),
            decoratorLabel.trailingAnchor.constraint(equalTo: decoratorContainerView.trailingAnchor, constant: -5)
        ])

        contentView.addSubview(decoratorContainerView)
        contentView.addSubview(textStackView)
        contentView.addSubview(capacityImageView)
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

    // MARK: - properties/functions

    func configureWithPrediction(_ prediction: Prediction, dividerVisible: Bool, animate: Bool) {
        capacityImageView.isHidden = prediction.capacity == nil
        dividerView.isHidden = !dividerVisible

        let capacityImageName = getCapacityImageName(capacity: prediction.capacity)
        let arrivalMessage = getArrivalMessage(arrivalTime: prediction.arrivalTime)

        if animate {
            if decoratorLabel.text != prediction.route {
                animateTextChange(prediction.route, view: decoratorLabel)
            }

            if titleLabel.text != prediction.title {
                animateTextChange(prediction.title, view: titleLabel)
            }

            if capacityImageName != self.capacityImageName {
                animateImageChange(capacityImageName, view: capacityImageView)
            }

            if arrivalTimeLabel.text != arrivalMessage {
                animateTextChange(arrivalMessage, view: arrivalTimeLabel)
            }

        } else {
            decoratorLabel.text = prediction.route
            titleLabel.text = prediction.title
            capacityImageView.image = UIImage(named: capacityImageName ?? "")?
                .withTintColor(Resources.Colors.capacity)
            arrivalTimeLabel.text = arrivalMessage
        }

        self.capacityImageName = capacityImageName
    }

    private func getArrivalMessage(arrivalTime: Date) -> String {
        let seconds = Int(arrivalTime.timeIntervalSinceNow)
        let arrivalMessage: String
        switch seconds {
        case Int.min...30:
            arrivalMessage = Resources.Strings.arrivingNow
        case 30..<120:
            arrivalMessage = Resources.Strings.arrivingIn1Min
        default:
            arrivalMessage = Resources.Strings.arrivingInNMins(Int(seconds / 60))
        }
        return arrivalMessage
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

    private func getCapacityImageName(capacity: Capacity?) -> String? {
        switch capacity {
        case .empty:
            return Resources.Images.capacityEmpty
        case .halfEmpty:
            return Resources.Images.capacityHalfEmpty
        case .full:
            return Resources.Images.capacityFull
        case .none:
            return nil
        }
    }

    private func animateImageChange(_ newImageName: String?, view: UIImageView) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            view.alpha = 0
        } completion: { _ in
            view.image = UIImage(named: newImageName ?? "")?
                .withTintColor(Resources.Colors.capacity)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
                view.alpha = 1
            }
        }
    }
}
