//
//  PredictionsViewModel.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class PredictionsViewModel {

    // MARK: - Publishers

    private let navBarStateSubject: CurrentValueSubject<PredictionsNavBarState, Never>

    var navBarState: AnyPublisher<PredictionsNavBarState, Never> {
        return navBarStateSubject.eraseToAnyPublisher()
    }

    private let dataStateSubject = CurrentValueSubject<PredictionsDataState, Never>(.loading)

    var dataState: AnyPublisher<PredictionsDataState, Never> {
        return dataStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private static let predictionsUpdateTime = TimeInterval(15)

    private let stop: TitleServiceStop

    private let stopService: StopService

    private let predictionService: PredictionService

    private let routeService: RouteService

    private weak var eventCoordinator: PredictionsEventCoordinator?

    private var cancellables: [AnyCancellable] = []

    private var predictionsCancellable: AnyCancellable?

    // MARK: - Initialization

    init(stop: TitleServiceStop,
         stopService: StopService,
         predictionService: PredictionService,
         routeService: RouteService,
         eventCoordinator: PredictionsEventCoordinator) {
        self.stop = stop
        self.stopService = stopService
        self.predictionService = predictionService
        self.routeService = routeService
        self.eventCoordinator = eventCoordinator
        self.navBarStateSubject = CurrentValueSubject<PredictionsNavBarState, Never>(
            PredictionsNavBarState(favorited: false, title: stop.title)
        )
        setupObserversForStop()
    }

    deinit {
        cancellables.removeAll()
        predictionsCancellable?.cancel()
    }

    // MARK: - Setup

    private func setupObserversForStop() {
        stopService.observeStopById(stop.id)
            .map { stop in PredictionsNavBarState(favorited: stop.favorite, title: stop.title) } // map to navbar state
            // set default navbar state if error occurs
            .replaceError(with: PredictionsNavBarState(favorited: false, title: ""))
            .receive(on: RunLoop.main)
            .subscribe(self.navBarStateSubject)
            .store(in: &cancellables)

        startObservingPredictions()
    }

    // MARK: - Intent Handling

    func handleIntent(_ intent: PredictionsIntent) {
        switch intent {
        case .toggleFavorited:
            self.handleToggleFavoritedIntent()
        case .filterRoutesSelected:
            self.handleFilterRoutesSelectedIntent()
        case .viewAppeared:
            self.startObservingPredictions()
        case .viewDisappeared:
            predictionsCancellable?.cancel()
            predictionsCancellable = nil
        }
    }

    private func handleToggleFavoritedIntent() {
        // If stop is favorited, unfavorite it and if stop if unfavorited, favorite it
        let publisher = navBarStateSubject.value.favorited
            ? stopService.unfavoriteStop(stop.id)
            : stopService.favoriteStop(stop.id)

        publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
    }

    private func handleFilterRoutesSelectedIntent() {
        eventCoordinator?.filterRoutesSelectedInFilterRoutes(stop.id)
    }

    private func startObservingPredictions() {
        predictionsCancellable = Publishers.CombineLatest(
            predictionTimerPublisher(stopId: stop.id, serviceType: stop.serviceType), // get the predictions
            routeService.observeExcludedRouteIdsForStopId(stop.id) // get the routes to exclude from predictions
        )
        .map { (predictions: [Prediction], excludedRouteIds: [String]) -> [Prediction] in
            let excludedRouteIdSet = Set(excludedRouteIds)
            return predictions
                .filter { prediction in
                    !excludedRouteIdSet.contains(prediction.route)
                }
                .sorted { (prediction1: Prediction, prediction2: Prediction) in
                    prediction1.arrivalTime.compare(prediction2.arrivalTime) == .orderedAscending
                }
        }
        .map { predictions -> PredictionsDataState in
            if predictions.isEmpty {
                return .noData
            } else {
                return .data(predictions)
            }
         }
        .replaceError(with: .error("Couldn't load predictions")) // set error state if error occurs
        .receive(on: RunLoop.main)
        .subscribe(self.dataStateSubject)
    }

    private func predictionTimerPublisher(stopId: String,
                                          serviceType: ServiceType) -> AnyPublisher<[Prediction], Error> {
        return Timer.publish(every: PredictionsViewModel.predictionsUpdateTime, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .flatMap { [unowned self] _ in
                self.predictionService.getPredictionsForStopId(stopId, serviceType: serviceType)
            }
            .eraseToAnyPublisher()
    }
}
