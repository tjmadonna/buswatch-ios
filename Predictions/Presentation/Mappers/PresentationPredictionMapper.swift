//
//  PresentationPredictionMapper.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/3/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import UIKit

public final class PresentationPredictionMapper {

    public init() { }

    func mapPredictionArrayToPresentationPredictionArray(_ predictions: [Prediction]?) -> [PresentationPrediction]? {
        guard let predictions = predictions else { return nil }

        let presentationPrediction = predictions
            .sorted(by: { $0.arrivalTime.compare($1.arrivalTime) == .orderedAscending })
            .compactMap { self.mapPredictionToDomainPrediction($0) }

        if presentationPrediction.isEmpty {
            return nil
        } else {
            return presentationPrediction
        }
    }

    func mapPredictionToDomainPrediction(_ prediction: Prediction?) -> PresentationPrediction? {
        guard let prediction = prediction else { return nil }

        let title: String
        if let routeTitle = prediction.routeTitle {
            title = "\(routeTitle) to \(prediction.destination) (\(prediction.direction))"
        } else {
            title = "\(prediction.destination) (\(prediction.direction))"
        }

        let capacity: String?
        switch prediction.capacity {
        case .empty:
            capacity =  "Empty"
        case .halfEmpty:
            capacity =  "Half Empty"
        case .full:
            capacity =  "Full"
        default:
            capacity = nil
        }

        let seconds = Int(prediction.arrivalTime.timeIntervalSinceNow)
        let arrivalMessage: String
        switch seconds {
        case Int.min...30:
            arrivalMessage = "Arriving Now"
        case 30..<120:
            arrivalMessage = "Arriving In 1 minute"
        default:
            arrivalMessage = "Arriving In \(Int(seconds / 60)) minutes"
        }

        return PresentationPrediction(
            vehicleId: prediction.vehicleId,
            title: title,
            route: prediction.routeId,
            capacity: capacity,
            arrivalMessage: arrivalMessage,
            color: UIColor(hex: prediction.routeColor)
        )
    }
}
