//
//  PredictionsService.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import GRDB
import MapKit

// MARK: - Service
protocol PredictionsServiceConformable {
    func observeFavoriteStateForStop(_ stopId: String) -> AnyPublisher<Bool, Swift.Error>
    func observePredictionsForStop(_ stop: PredictionsStop, updateInterval: TimeInterval) -> AnyPublisher<LoadingResponse<[Prediction]>, Swift.Error>
    func observeExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Swift.Error>
    func unfavoriteStop(_ stopId: String) async -> Result<Void, Swift.Error>
    func favoriteStop(_ stopId: String) async -> Result<Void, Swift.Error>
}

final class PredictionsService: PredictionsServiceConformable {

    private let database: DatabaseConformable

    private let urlSession: URLSession

    private let urlSource: UrlSourceConformable

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyyMMdd HH:mm"
        return dateFormatter
    }()

    init(database: DatabaseConformable,
         urlSession: URLSession,
         urlSource: UrlSourceConformable) {
        self.database = database
        self.urlSession = urlSession
        self.urlSource = urlSource
    }

    private func getRoutesWithIds(_ routeIds: [String]) -> Result<[Route], Swift.Error> {
        let idSet = Set(routeIds)
        let placeHolderString = Array(repeating: "?", count: idSet.count).joined(separator: ", ")
        let sql = """
        SELECT \(RoutesTable.idColumn), \(RoutesTable.titleColumn)
        FROM \(RoutesTable.tableName)
        WHERE \(RoutesTable.idColumn) IN (\(placeHolderString))
        """
        let arguments = StatementArguments(Array(idSet))
        do {
            let routes = try database.queue.read { db in
                return try Route.fetchAll(db, sql: sql, arguments: arguments)
            }
            return .success(routes)
        } catch {
            return .failure(error)
        }
    }

    func observeFavoriteStateForStop(_ stopId: String) -> AnyPublisher<Bool, Swift.Error> {
        let sql = """
        SELECT s.\(StopsTable.idColumn), f.\(FavoriteStopsTable.stopIdColumn)
        FROM \(StopsTable.tableName) AS s
        LEFT JOIN \(FavoriteStopsTable.tableName) AS f
        ON s.\(StopsTable.idColumn) = f.\(FavoriteStopsTable.stopIdColumn)
        WHERE s.\(StopsTable.idColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return database.queue
            .fetchOneValueObservationPublisherForSql(sql, arguments: arguments)
            .map { (stop: PredictionsFavoriteStop) in
                stop.stopId != nil
            }
            .eraseToAnyPublisher()
    }

    func observeExcludedRouteIdsForStopId(_ stopId: String) -> AnyPublisher<[String], Swift.Error> {
        let sql = """
        SELECT \(ExcludedRoutesTable.routesColumn) FROM \(ExcludedRoutesTable.tableName)
        WHERE \(ExcludedRoutesTable.stopIdColumn) = ?
        """
        let arguments = StatementArguments([stopId])
        return ValueObservation.tracking { db in
            return try String.fetchOne(db, sql: sql, arguments: arguments)?
                .components(separatedBy: ExcludedRoutesTable.routesDelimiter) ?? []
        }
        .publisher(in: database.queue)
        .eraseToAnyPublisher()
    }

    func unfavoriteStop(_ stopId: String) async -> Result<Void, Swift.Error> {
        let sql = """
        DELETE FROM \(FavoriteStopsTable.tableName)
        WHERE \(FavoriteStopsTable.stopIdColumn) = ?
        """
        do {
            try await database.queue.write { db in
                try db.execute(sql: sql, arguments: [stopId])
            }
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }

    func favoriteStop(_ stopId: String) async -> Result<Void, Swift.Error> {
        let sql = """
        INSERT OR IGNORE INTO \(FavoriteStopsTable.tableName)
        (\(FavoriteStopsTable.stopIdColumn)) VALUES (?)
        """
        do {
            try await database.queue.write { db in
                try db.execute(sql: sql, arguments: [stopId])
            }
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }

    func observePredictionsForStop(_ stop: PredictionsStop, updateInterval: TimeInterval) -> AnyPublisher<LoadingResponse<[Prediction]>, Swift.Error> {
        let url = urlSource.authenticatedPredictionsURLForStopId(stop.id, serviceType: stop.serviceType)
        return TimedNetworkPublisher<NetworkGetPredictionsResponse>(url: url, timeInterval: updateInterval, urlSession: urlSession)
            .map { [unowned self] response in self.tryToMapToNetworkPredictions(response) }
            .map { [unowned self] networkPredictions in self.tryToMapToPredictions(networkPredictions) }
            .eraseToAnyPublisher()
    }

    private func tryToMapToNetworkPredictions(_ response: LoadingResponse<NetworkGetPredictionsResponse>) -> LoadingResponse<[NetworkPrediction]> {
        switch response {
        case .loading:
            return .loading
        case .success(let res):
            let networkPredictions = res.bustimeResponse?.predictions ?? []
            return .success(networkPredictions)
        case .failure(let error):
            return .failure(error)
        }
    }

    private func tryToMapToPredictions(_ networkPredictions: LoadingResponse<[NetworkPrediction]>) -> LoadingResponse<[Prediction]> {
        switch networkPredictions {
        case .loading:
            return .loading
        case .success(let networkPredictions):
            let routeIds = networkPredictions.compactMap { prediction in prediction.routeId }
            let routesResult = getRoutesWithIds(routeIds)
            switch routesResult {
            case .success(let routes):
                let routeMap = Dictionary(uniqueKeysWithValues: routes.map { route in (route.id, route) })
                let predictions = networkPredictions.compactMap { prediction in
                    self.tryToMapToPrediction(prediction, route: routeMap[prediction.routeId ?? ""])
                }
                return .success(predictions)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    private func tryToMapToPrediction(_ networkPrediction: NetworkPrediction, route: Route?) -> Prediction? {
        guard let vehicleId = networkPrediction.vehicleId else { return nil }
        guard let routeId = networkPrediction.routeId else { return nil }
        guard let destination = networkPrediction.destination?.capitalizingOnlyFirstLetters() else { return nil }
        guard let routeDirection = networkPrediction.routeDirection?.capitalizingOnlyFirstLetters() else { return nil }
        guard let arrivalTimeStr = networkPrediction.arrivalTime else { return nil }
        guard let arrivalTime = PredictionsService.dateFormatter.date(from: arrivalTimeStr) else { return nil }

        let capacity = getCapacityType(networkPrediction.capacity)

        let title: String
        if let routeTitle = route?.title {
            title = Resources.Strings.predictionTitleWithRoute(routeTitle, destination, routeDirection)
        } else {
            title = Resources.Strings.predictionTitleNoRoute(destination, routeDirection)
        }

        return Prediction(
            id: vehicleId,
            title: title,
            route: routeId,
            capacity: capacity,
            arrivalInSeconds: Int(arrivalTime.timeIntervalSinceNow)
        )
    }

    private func getCapacityType(_ capacityString: String?) -> Capacity? {
        switch capacityString?.lowercased() {
        case "empty":
            return .empty
        case "half_empty":
            return .halfEmpty
        case "full":
            return .full
        default:
            return nil
        }
    }
    
}
