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

    private let stop: PredictionsStop

    private let service: PredictionsServiceConformable

    private weak var eventCoordinator: PredictionsEventCoordinator?

    private var cancellables: [AnyCancellable] = []

    private var predictionsCancellable: AnyCancellable?

    // MARK: - Initialization

    init(stop: PredictionsStop,
         service: PredictionsServiceConformable,
         eventCoordinator: PredictionsEventCoordinator) {
        self.stop = stop
        self.service = service
        self.eventCoordinator = eventCoordinator
        self.navBarStateSubject = CurrentValueSubject<PredictionsNavBarState, Never>(
            PredictionsNavBarState(favorited: false, title: stop.title)
        )
        setupObservers()
    }

    deinit {
        cancelPredictionsPublisher()
        cancellables.removeAll()
        print("Deinniting predictions view model")
    }

    // MARK: - Setup

    private func setupObservers() {
        startObservingNavBarState()
        startObservingPredictions()
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

        if navBarStateSubject.value.favorited {
            Task.init {
                if case .failure(let error) = await service.unfavoriteStop(stop.id) {
                    print(error)
                }
            }
        } else {
            Task.init {
                if case .failure(let error) = await service.favoriteStop(stop.id) {
                    print(error)
                }
            }
        }
    }

    private func handleFilterRoutesSelectedIntent() {
        eventCoordinator?.filterRoutesSelectedInFilterRoutes(stop.id)
    }

    private func startObservingNavBarState() {
        service.observeFavoriteStateForStop(stop.id)
            .map { [unowned self] favorited in PredictionsNavBarState(favorited: favorited, title: self.stop.title) }
            .replaceError(with: PredictionsNavBarState(favorited: false, title: ""))
            .receive(on: RunLoop.main)
            .subscribe(self.navBarStateSubject)
            .store(in: &cancellables)
    }

    private func startObservingPredictions() {
        cancelPredictionsPublisher()

        // Update data everytime the predictions or excluded routes changes
        predictionsCancellable = Publishers.CombineLatest(
            service.observePredictionsForStop(stop, updateInterval: 15),
            service.observeExcludedRouteIdsForStopId(stop.id)
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

    private func cancelPredictionsPublisher() {
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
