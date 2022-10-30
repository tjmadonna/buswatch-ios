//
//  OverviewMapCell.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/18/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit
import UIKit

final class OverviewMapCell: UITableViewCell {

    static let reuseId = "OverviewMapCell"

    // MARK: - Subviews

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.layer.cornerRadius = 10
        map.isUserInteractionEnabled = false
        return map
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
        accessoryType = .disclosureIndicator

        contentView.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 9 / 16.0),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mapView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8)
                .usingPriority(.defaultLow),
            mapView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
                .usingPriority(.defaultLow)
        ])
    }

    // MARK: - Properties/functions

    func configureWithCoordinateRegion(_ coordinateRegion: MKCoordinateRegion) {
        mapView.setRegion(coordinateRegion, animated: false)
    }

}
