//
//  PredictionsViewModel.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/25/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import UIKit

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

    private let loadingStateSubject = CurrentValueSubject<Bool, Never>(true)

    var loadingState: AnyPublisher<Bool, Never> {
        return loadingStateSubject.eraseToAnyPublisher()
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
        setupObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        cancelPredictionsPublisher()
        cancellables.removeAll()
        print("Deinniting predictions view model")
    }

    // MARK: - Setup

    private func setupObservers() {
        startObservingNavBarState()
        startObservingPredictions()
        startObservingAppNotifications()
    }

    // MARK: - Intent Handling

    func handleIntent(_ intent: PredictionsIntent) {
        switch intent {
        case .toggleFavorited:
            self.handleToggleFavoritedIntent()
        case .filterRoutesSelected:
            self.handleFilterRoutesSelectedIntent()
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

    private func startObservingAppNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cancelPredictionsPublisher),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(startObservingPredictions),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    private func startObservingNavBarState() {
        stopService.observeStopById(stop.id)
            // map to navbar state
            .map { stop in PredictionsNavBarState(favorited: stop.favorite, title: stop.title) }
            // set default navbar state if error occurs
            .replaceError(with: PredictionsNavBarState(favorited: false, title: ""))
            .receive(on: RunLoop.main)
            .subscribe(self.navBarStateSubject)
            .store(in: &cancellables)
    }

    @objc private func startObservingPredictions() {
        cancelPredictionsPublisher()

        print("Starting prediction call")
        // Update data everytime the predictions or excluded routes changes
        predictionsCancellable = Publishers.CombineLatest(
            predictionService.observePredictionsForStopId(stop.id, serviceType: stop.serviceType, updateInterval: 15),
            routeService.observeExcludedRouteIdsForStopId(stop.id)
        )
        .map { [unowned self] (response, excludedRouteIds) in
            self.mapToPredictions(response: response, excludedRouteIds: excludedRouteIds)
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            print(completion)
        }, receiveValue: { [weak self] response in
            self?.receivePredictionsResponse(response)
        })
    }

    @objc private func cancelPredictionsPublisher() {
        print("Cancelling prediction call")
        predictionsCancellable?.cancel()
        predictionsCancellable = nil
    }

    private func mapToPredictions(response: LoadingResponse<[Prediction]>,
                                  excludedRouteIds: [String]) -> LoadingResponse<[Prediction]> {
        switch response {
        case .loading:
            return .loading
        case .success(let predictions):
            let excludedRouteIdSet = Set(excludedRouteIds)
            return .success(predictions
                .filter { prediction in
                    !excludedRouteIdSet.contains(prediction.route)
                }
                .sorted { (prediction1: Prediction, prediction2: Prediction) in
                    prediction1.arrivalInSeconds < prediction2.arrivalInSeconds
                })
        case .failure(let error):
            return .failure(error)
        }
    }

    private func receivePredictionsResponse(_ response: LoadingResponse<[Prediction]>) {
        switch response {
        case .loading:
            loadingStateSubject.value = true
        case .success(let predictions):
            loadingStateSubject.value = false
            if predictions.isEmpty {
                dataStateSubject.value = .noData
            } else {
                dataStateSubject.value = .data(predictions)
            }
        case .failure(let error):
            loadingStateSubject.value = false
            print(error)
        }
    }
}
