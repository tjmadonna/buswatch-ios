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

    private let stopRepository: OverviewStopRepository

    private let locationRepository: OverviewLocationRepository

    private weak var eventCoordinator: OverviewEventCoordinator?

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(stopRepository: OverviewStopRepository,
         locationRepository: OverviewLocationRepository,
         eventCoordinator: OverviewEventCoordinator) {
        self.stopRepository = stopRepository
        self.locationRepository = locationRepository
        self.eventCoordinator = eventCoordinator
        setupObservers()
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - Setup

    private func setupObservers() {
        Publishers.CombineLatest(stopRepository.getFavoriteStops(), locationRepository.getLastLocationBounds())
            .map { [unowned self] (stops, locationBounds) in
                self.mapToOverviewSections(stops: stops, locationBounds: locationBounds)
            }
            .map { sections in OverviewState.data(sections) }
            .replaceError(with: .error("Couldn't get favorite stops"))
            .receive(on: RunLoop.main)
            .subscribe(self.stateSubject)
            .store(in: &cancellables)
    }

    private func mapToOverviewSections(stops: [OverviewFavoriteStop],
                                       locationBounds: OverviewLocationBounds) -> [OverviewSection] {
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

    // MARK: - Intent Handling

    func handleIntent(_ intent: OverviewIntent) {
        switch intent {
        case .favoriteStopSelected(let favoriteStop):
            self.eventCoordinator?.favoriteStopSelectedInOverview(favoriteStop.id)
        case .stopMapSelected:
            self.eventCoordinator?.stopMapSelectedInOverview()
        }
    }
}
