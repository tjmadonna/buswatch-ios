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

    private let navBarStateSubject = CurrentValueSubject<PredictionsNavBarState, Never>(
        PredictionsNavBarState(favorited: false, title: "")
    )

    var navBarState: AnyPublisher<PredictionsNavBarState, Never> {
        return navBarStateSubject.eraseToAnyPublisher()
    }

    private let dataStateSubject = CurrentValueSubject<PredictionsDataState, Never>(.loading)

    var dataState: AnyPublisher<PredictionsDataState, Never> {
        return dataStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private let stopId: String

    private let getStopById: PredictionsGetStopById

    private let getPredictionsForStopId: PredictionsGetPredictionsForStopId

    private let favoriteStop: PredictionsFavoriteStop

    private let unfavoriteStop: PredictionsUnfavoriteStop

    private weak var eventCoordinator: PredictionsEventCoordinator?

    private let predictionMapper: PredictionsPresentationPredictionMapper

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(stopId: String,
         getStopById: PredictionsGetStopById,
         getPredictionsForStopId: PredictionsGetPredictionsForStopId,
         favoriteStop: PredictionsFavoriteStop,
         unfavoriteStop: PredictionsUnfavoriteStop,
         eventCoordinator: PredictionsEventCoordinator,
         predictionMapper: PredictionsPresentationPredictionMapper) {
        self.stopId = stopId
        self.getStopById = getStopById
        self.getPredictionsForStopId = getPredictionsForStopId
        self.favoriteStop = favoriteStop
        self.unfavoriteStop = unfavoriteStop
        self.eventCoordinator = eventCoordinator
        self.predictionMapper = predictionMapper
        setupObserversForStop()
    }

    deinit {
        cancellables.removeAll()
        print("Deinniting PredictionsViewModel")
    }

    // MARK: - Setup

    private func setupObserversForStop() {
        getStopById.execute(stopId: stopId)
            .map { stop in PredictionsNavBarState(favorited: stop.favorite, title: stop.title) } // map to navbar state
            // set default navbar state if error occurs
            .replaceError(with: PredictionsNavBarState(favorited: false, title: ""))
            .receive(on: RunLoop.main)
            .subscribe(self.navBarStateSubject)
            .store(in: &cancellables)

        getPredictionsForStopId.execute(stopId: stopId)
            .map { [weak self] in self?.predictionMapper.mapPredictionArrayToPresentationPredictionArray($0) }
            .map { predictions -> PredictionsDataState in
                if let predictions = predictions {
                    return .data(predictions)
                } else {
                    return .noData
                }
             }
            .replaceError(with: .error("Couldn't load predictions")) // set error state if error occurs
            .receive(on: RunLoop.main)
            .subscribe(self.dataStateSubject)
            .store(in: &cancellables)
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
            ? unfavoriteStop.execute(stopId: stopId)
            : favoriteStop.execute(stopId: stopId)

        publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // TODO: handle error
                    print(error)
                }
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
    }

    private func handleFilterRoutesSelectedIntent() {
        eventCoordinator?.filterRoutesSelectedInFilterRoutes(stopId)
    }
}