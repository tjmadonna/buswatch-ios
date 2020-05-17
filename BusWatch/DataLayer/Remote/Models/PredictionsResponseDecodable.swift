//
//  PredictionsResponseDecodable.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/1/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation

struct PredictionsResponseDecodable: Decodable {

    let predictions: [PredictionDecodable]?

    private enum CodingKeys: String, CodingKey {
        case predictions = "predictions"
    }
}
