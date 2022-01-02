//
//  FilterRoutesViewModel.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/18/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine

public final class FilterRoutesViewModel {

    // MARK: - Publishers

    private let stateSubject = CurrentValueSubject<FilterRoutesState, Never>(.loading)

    var state: AnyPublisher<FilterRoutesState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private let stopId: String

    private let getRoutesForStopId: GetRoutesForStopId

    private let updateExcludedRoutes: UpdateExcludedRoutes

    private weak var eventCoordinator: FilterRoutesEventCoordinator?

    private let routeMapper: PresentationRouteMapper

    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization

    public init(stopId: String,
                getRoutesForStopId: GetRoutesForStopId,
                updateExcludedRoutes: UpdateExcludedRoutes,
                eventCoordinator: FilterRoutesEventCoordinator,
                routeMapper: PresentationRouteMapper = PresentationRouteMapper()) {
        self.stopId = stopId
        self.getRoutesForStopId = getRoutesForStopId
        self.updateExcludedRoutes = updateExcludedRoutes
        self.eventCoordinator = eventCoordinator
        self.routeMapper = routeMapper
        setupObservers()
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - Setup

    private func setupObservers() {
        getRoutesForStopId.execute(stopId: stopId)
            .compactMap { routes in self.routeMapper.mapRouteArrayToPresentationRouteArray(routes) }
            .map { routes in FilterRoutesState.data(routes) }
            .replaceError(with: .error("Couldn't get routes"))
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
            let newRoute = PresentationRoute(routeId: currentRoute.routeId, selected: !currentRoute.selected)
            routes[index] = newRoute
            stateSubject.value = .data(routes)
        }
    }

    private func handleCancelSelectedIntent() {
        eventCoordinator?.cancelSelectedInFilterRoutes()
    }

    private func handleSaveSelectedIntent() {
        if case .data(let routes) = stateSubject.value {

            let excludedRouteIds = routes.filter { route in !route.selected }
                .map { route in route.routeId }
            updateExcludedRoutes.execute(routeIds: excludedRouteIds, stopId: stopId)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { [weak self] _ in
                    self?.eventCoordinator?.cancelSelectedInFilterRoutes()
                })
                .store(in: &cancellables)
        }
    }
}
