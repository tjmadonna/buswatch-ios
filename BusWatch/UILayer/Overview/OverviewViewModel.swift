//
//  OverviewViewModel.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/23/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class OverviewViewModel {

    // MARK: - Publishers

    private let stateSubject = CurrentValueSubject<OverviewState, Never>(.loading)

    var state: AnyPublisher<OverviewState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private let stopLocalDataStore: StopLocalDataStore

    private let locationLocalDataStore: LocationLocalDataStore

    private weak var appCoordinator: AppCoordinator?

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(stopLocalDataStore: StopLocalDataStore, locationLocalDataStore: LocationLocalDataStore, appCoordinator: AppCoordinator) {
        self.stopLocalDataStore = stopLocalDataStore
        self.locationLocalDataStore = locationLocalDataStore
        self.appCoordinator = appCoordinator
        setupObservers()
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - Setup

    private func setupObservers() {
        Publishers.CombineLatest(stopLocalDataStore.getFavoriteStops(), locationLocalDataStore.getLastLocationBounds())
            .map { [unowned self] (stops, locationBounds) in self.mapToOverviewSections(stops: stops, locationBounds: locationBounds) }
            .map { sections in OverviewState.data(sections) }
            .replaceError(with: .error("Couldn't get favorite stops"))
            .receive(on: RunLoop.main)
            .subscribe(self.stateSubject)
            .store(in: &cancellables)
    }

    private func mapToOverviewSections(stops: [Stop], locationBounds: LocationBounds) -> [OverviewSection] {
        if stops.isEmpty {
            return [
                OverviewSection(title: "Favorite Stops", items: [.emptyFavoriteStop]),
                OverviewSection(title: "Map", items: [.map(locationBounds)])
            ]
        } else {
            return [
                OverviewSection(title: "Favorite Stops", items: stops.map { stop in .favoriteStop(stop) }),
                OverviewSection(title: "Map", items: [.map(locationBounds)])
            ]
        }
    }

    func handlePresentStopMapViewController() {
        appCoordinator?.presentStopMapViewController()
    }

    func handlePresentPredictionsViewControllerForStop(_ stop: Stop) {
        appCoordinator?.presentPredictionsViewControllerForStop(stop)
    }
}
