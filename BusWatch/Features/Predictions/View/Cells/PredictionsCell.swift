//
//  PredictionsCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

final class PredictionsCell: UITableViewCell {

    static let reuseId = "PredictionsCell"

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
        let stackView = UIStackView(arrangedSubviews: [titleLabel, arrivalTimeLabel])
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

    private let arrivalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private let capacityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [decoratorContainerView, textStackView, capacityImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.setCustomSpacing(5, after: textStackView)
        return stackView
    }()

    private var capacityImageName: String?

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) cannot be used to create view")
    }
}

extension PredictionsCell {

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
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11)
        ])

        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: textStackView.widthAnchor),
            arrivalTimeLabel.widthAnchor.constraint(equalTo: textStackView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            decoratorContainerView.widthAnchor.constraint(equalToConstant: 60),
            decoratorContainerView.heightAnchor.constraint(equalToConstant: 60)
        ])

        NSLayoutConstraint.activate([
            capacityImageView.widthAnchor.constraint(equalToConstant: 35),
            capacityImageView.heightAnchor.constraint(equalToConstant: 27)
        ])
    }

}

// MARK: - Public functions
extension PredictionsCell {

    func configureWithPrediction(_ prediction: PredictionsPredictionDataItem, animate: Bool) {
        capacityImageView.isHidden = prediction.capacity == nil

        let capacityImageName = getCapacityImageName(capacity: prediction.capacity)
        let arrivalMessage = getArrivalMessage(arrivalInSeconds: prediction.arrivalInSeconds)

        if animate {
            if decoratorLabel.text != prediction.route {
                animateTextChange(prediction.route, view: decoratorLabel)
            }

            if titleLabel.text != prediction.title {
                animateTextChange(prediction.title, view: titleLabel)
            }

            if arrivalTimeLabel.text != arrivalMessage {
                animateTextChange(arrivalMessage, view: arrivalTimeLabel)
            }

            if capacityImageName != self.capacityImageName {
                animateImageChange(capacityImageName, view: capacityImageView)
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

    private func getArrivalMessage(arrivalInSeconds: Int) -> String {
        let arrivalMessage: String
        switch arrivalInSeconds {
        case Int.min...30:
            arrivalMessage = Resources.Strings.arrivingNow
        case 30..<120:
            arrivalMessage = Resources.Strings.arrivingIn1Min
        default:
            arrivalMessage = Resources.Strings.arrivingInNMins(Int(arrivalInSeconds / 60))
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
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
                view.alpha = 1
            }
        }
    }

}
