//
//  OverviewViewModel.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/23/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Combine
import Foundation
import MapKit

final class OverviewViewModel {

    // MARK: - Publishers

    private let stateSubject = CurrentValueSubject<OverviewState, Never>(.loading)

    var state: AnyPublisher<OverviewState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private let service: OverviewServiceConformable

    private weak var eventCoordinator: OverviewEventCoordinator?

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(service: OverviewServiceConformable, eventCoordinator: OverviewEventCoordinator) {
        self.service = service
        self.eventCoordinator = eventCoordinator
        setupObservers()
    }

    deinit {
        cancellables.removeAll()
    }

}

// MARK: - Setup
extension OverviewViewModel {

    private func setupObservers() {
        Publishers.CombineLatest(service.observeFavoriteStops(), service.observeLastCoordinateRegion())
            .map { [unowned self] (stops, coordinateRegion) in
                self.mapToOverviewSections(stops: stops, coordinateRegion: coordinateRegion)
            }
            .map { sections in OverviewState.data(sections) }
            .replaceError(with: .error("Couldn't get favorite stops"))
            .receive(on: RunLoop.main)
            .subscribe(self.stateSubject)
            .store(in: &cancellables)
    }

}

// MARK: - Mappers
extension OverviewViewModel {

    private func mapToOverviewSections(stops: [OverviewFavoriteStop], coordinateRegion: MKCoordinateRegion) -> [OverviewSection] {
        if stops.isEmpty {
            return [
                OverviewSection(title: "Favorite Stops", items: [.emptyFavoriteStop]),
                OverviewSection(title: "Map", items: [.map(coordinateRegion)])
            ]
        } else {
            return [
                OverviewSection(title: "Favorite Stops", items: stops.map { stop in .favoriteStop(stop) }),
                OverviewSection(title: "Map", items: [.map(coordinateRegion)])
            ]
        }
    }

}

// MARK: - Intent Handling
extension OverviewViewModel {

    func handleIntent(_ intent: OverviewIntent) {
        switch intent {
        case .favoriteStopSelected(let favoriteStop):
            self.eventCoordinator?.favoriteStopSelectedInOverview(favoriteStop)
        case .stopMapSelected:
            self.eventCoordinator?.stopMapSelectedInOverview()
        case .settingsSelected:
            self.eventCoordinator?.settingsSelectedInOverview()
        }
    }

}
