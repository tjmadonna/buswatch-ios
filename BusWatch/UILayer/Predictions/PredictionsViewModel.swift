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

    private let navBarStateSubject = CurrentValueSubject<PredictionsNavBarState, Never>(PredictionsNavBarState(favorited: false))

    var navBarState: AnyPublisher<PredictionsNavBarState, Never> {
        return navBarStateSubject.eraseToAnyPublisher()
    }

    private let dataStateSubject = CurrentValueSubject<PredictionsDataState, Never>(.loading)

    var dataState: AnyPublisher<PredictionsDataState, Never> {
        return dataStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private let stopId: String

    private let stopLocalDataStore: StopLocalDataStore

    private let predictionRemoteDataStore: PredictionRemoteDataStore

    private weak var appCoordinator: AppCoordinator?

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(stop: Stop,
         stopLocalDataStore: StopLocalDataStore,
         predictionRemoteDataStore: PredictionRemoteDataStore,
         appCoordinator: AppCoordinator) {
        self.stopId = stop.id
        self.stopLocalDataStore = stopLocalDataStore
        self.predictionRemoteDataStore = predictionRemoteDataStore
        self.appCoordinator = appCoordinator
        setupObserversForStop()
    }

    deinit {
        cancellables.removeAll()
        print("Deinniting PredictionsViewModel")
    }

    // MARK: - Setup

    private func setupObserversForStop() {
        stopLocalDataStore.getStopById(stopId)
            .map { stop in PredictionsNavBarState(favorited: stop.favorite) } // map to navbar state
            .replaceError(with: PredictionsNavBarState(favorited: false)) // set default navbar state if error occurs
            .receive(on: RunLoop.main)
            .subscribe(self.navBarStateSubject)
            .store(in: &cancellables)

        predictionRemoteDataStore.getPredictionsForStopId(stopId)
            .map { predictions in predictions.sorted(by: { (prd1, prd2) in prd1.arrivalTime < prd2.arrivalTime }) } // sort by arrivalTime
            .map { [unowned self] predictions in self.mapToPredictionItems(predictions) } // map to prediction item
            .map { predictionItems in .data(predictionItems) } // map to date state
            .replaceError(with: .error("Couldn't load predictions")) // set error state if error occurs
            .receive(on: RunLoop.main)
            .subscribe(self.dataStateSubject)
            .store(in: &cancellables)
    }

    private func mapToPredictionItems(_ predictions: [Prediction]) -> [PredictionItem] {
        if predictions.isEmpty {
            return [ .emptyPrediction ]
        } else {
            return predictions.map { prediction in .prediction(prediction) }
        }
    }

    // MARK: - Intent Handling

    func handleIntent(_ intent: PredictionsIntent) {
        switch intent {
        case .toggleFavorited:
            self.handleToggleFavoritedIntent()
        }
    }

    func handleToggleFavoritedIntent() {
        // If stop is favorited, unfavorite it and if stop if unfavorited, favorite it
        let publisher = navBarStateSubject.value.favorited
            ? stopLocalDataStore.unfavoriteStop(stopId)
            : stopLocalDataStore.favoriteStop(stopId)

        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // TODO: handle error
                    print(error)
                }
            }) { _ in
        }.store(in: &cancellables)
    }
}
