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

    private let titleStateSubject: CurrentValueSubject<String, Never>

    var titleState: AnyPublisher<String, Never> {
        return titleStateSubject.eraseToAnyPublisher()
    }

    private let favoriteStateSubject: CurrentValueSubject<Bool, Never> = .init(false)

    var favoriteState: AnyPublisher<Bool, Never> {
        return favoriteStateSubject.eraseToAnyPublisher()
    }

    private let dataStateSubject: CurrentValueSubject<[any PredictionsDataItemConformable], Never>
        = .init([PredictionsMessageDataItem(message: "Loading...")])

    var dataState: AnyPublisher<[any PredictionsDataItemConformable], Never> {
        return dataStateSubject.eraseToAnyPublisher()
    }

    private let loadingStateSubject: CurrentValueSubject<Bool, Never> = .init(true)

    var loadingState: AnyPublisher<Bool, Never> {
        return loadingStateSubject.eraseToAnyPublisher()
    }

    private let lastUpdatedSubject: CurrentValueSubject<Date?, Never> = .init(nil)

    var lastUpdated: AnyPublisher<Date?, Never> {
        return lastUpdatedSubject
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Properties

    private static let predictionsUpdateTime = TimeInterval(15)

    private let stop: PredictionsStop

    private let service: PredictionsServiceConformable

    private weak var eventCoordinator: PredictionsEventCoordinator?

    private var initialLoad: Bool = true

    private var cancellables: [AnyCancellable] = []

    private var predictionsCancellable: AnyCancellable?

    private var lastUpdatedTimer: Timer?

    // MARK: - Initialization

    init(stop: PredictionsStop,
         service: PredictionsServiceConformable,
         eventCoordinator: PredictionsEventCoordinator) {
        self.stop = stop
        self.service = service
        self.eventCoordinator = eventCoordinator
        self.titleStateSubject = .init(stop.title)
        setupTimer()
        setupObservers()
    }

    deinit {
        lastUpdatedTimer?.invalidate()
        cancelPredictionsPublisher()
        cancellables.removeAll()
        print("Deinniting predictions view model")
    }

    // MARK: - Setup

    private func setupTimer() {
        lastUpdatedTimer = Timer.scheduledTimer(timeInterval: 30,
                                                target: self,
                                                selector: #selector(updateLastUpdated),
                                                userInfo: nil,
                                                repeats: true)
    }

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
        if favoriteStateSubject.value {
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
            .replaceError(with: false)
            .receive(on: RunLoop.main)
            .subscribe(self.favoriteStateSubject)
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
            self.lastUpdatedSubject.value = Date()
            let excludedRouteIdSet = Set(excludedRouteIds)
            return .success(predictions
                .filter { prediction in
                    !excludedRouteIdSet.contains(prediction.route)
                }
                .sorted { (prediction1: Prediction, prediction2: Prediction) in
                    prediction1.arrivalInSeconds < prediction2.arrivalInSeconds
                })
        case .failure(let error):
            print(error)
            return .failure(error)
        }
    }

    private func receivePredictionsResponse(_ response: LoadingResponse<[Prediction]>) {
        switch response {
        case .loading:
            loadingStateSubject.value = true
        case .success(let predictions):
            initialLoad = false
            loadingStateSubject.value = false
            if predictions.isEmpty {
                dataStateSubject.value = [PredictionsMessageDataItem(message: "No arrival times")]
            } else {
                dataStateSubject.value = predictions.map { PredictionsPredictionDataItem(prediction: $0) }
            }
        case .failure(let error):
            loadingStateSubject.value = false
            if initialLoad {
                dataStateSubject.value = [PredictionsMessageDataItem(message: error.localizedDescription)]
            }
            print(error)
        }
    }

    @objc private func updateLastUpdated() {
        self.lastUpdatedSubject.value = self.lastUpdatedSubject.value
    }

}
