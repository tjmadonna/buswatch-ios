//
//  FilterRoutesViewModel.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

final class FilterRoutesViewModel {

    // MARK: - Publishers

    private let stateSubject = CurrentValueSubject<FilterRoutesState, Never>(.loading)

    var state: AnyPublisher<FilterRoutesState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private let stopId: String

    private let routeService: RouteService

    private weak var eventCoordinator: FilterRoutesEventCoordinator?

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    init(stopId: String,
         routeService: RouteService,
         eventCoordinator: FilterRoutesEventCoordinator) {
        self.stopId = stopId
        self.routeService = routeService
        self.eventCoordinator = eventCoordinator
        setupObservers()
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - Setup

    private func setupObservers() {
        routeService.observeFilterableRoutesForStopId(stopId)
            .map { routes in routes.sorted { route1, route2 in route1.id.compare(route2.id) == .orderedAscending }}
            .map { routes in FilterRoutesState.data(routes) }
            .replaceError(with: FilterRoutesState.error("Couldn't get routes"))
            .receive(on: RunLoop.main)
            .subscribe(self.stateSubject)
            .store(in: &cancellables)
    }

    // MARK: - Intent Handling

    func handleIntent(_ intent: FilterRoutesIntent) {
        switch intent {
        case .routeSelected(let routeIndex):
            handleRouteSelectedIntent(routeIndex)
        case .cancelSelected:
            handleCancelSelectedIntent()
        case .saveSelected:
            handleSaveSelectedIntent()
        }
    }

    private func handleRouteSelectedIntent(_ index: Int) {
        if case .data(var routes) = stateSubject.value {
            let currentRoute = routes[index]
            let newRoute = FilterableRoute(id: currentRoute.id,
                                           filtered: !currentRoute.filtered)
            routes[index] = newRoute
            stateSubject.value = .data(routes)
        }
    }

    private func handleCancelSelectedIntent() {
        eventCoordinator?.cancelSelectedInFilterRoutes()
    }

    private func handleSaveSelectedIntent() {
        if case .data(let routes) = stateSubject.value {

            let excludedRouteIds = routes.filter { route in route.filtered }
                .map { route in route.id }

            routeService.updateExcludedRouteIdsForStopId(stopId, routeIds: excludedRouteIds)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { [weak self] _ in
                    self?.eventCoordinator?.cancelSelectedInFilterRoutes()
                })
                .store(in: &cancellables)
        }
    }
}
