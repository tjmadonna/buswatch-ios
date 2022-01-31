//
//  PredictionsNetworkPrediction.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/1/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

struct PredictionsNetworkPrediction: Decodable {

    let vehicleId: String?

    let routeId: String?

    let destination: String?

    let routeDirection: String?

    let arrivalTime: String?

    let capacity: String?

    private enum CodingKeys: String, CodingKey {
        case vehicleId = "vid"
        case routeId = "rt"
        case destination = "des"
        case routeDirection = "rtdir"
        case arrivalTime = "prdtm"
        case capacity = "psgld"
    }
}

struct PredictionsNetworkPredictionError: Decodable {

    let dataFeed: String?

    let stopId: String?

    let message: String?

    private enum CodingKeys: String, CodingKey {
        case dataFeed = "rtpidatafeed"
        case stopId = "stpid"
        case message = "msg"
    }
}

struct PredictionsNetworkBustimeResponse: Decodable {

    let predictions: [PredictionsNetworkPrediction]?

    let errors: [PredictionsNetworkPredictionError]?

    private enum CodingKeys: String, CodingKey {
        case predictions = "prd"
        case errors = "error"
    }
}

struct PredictionsNetworkGetPredictionsResponse: Decodable {

    let bustimeResponse: PredictionsNetworkBustimeResponse?

    enum CodingKeys: String, CodingKey {
        case bustimeResponse = "bustime-response"
    }
}
