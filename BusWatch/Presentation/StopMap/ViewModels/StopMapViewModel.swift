//
//  StopMapViewModel.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

final class StopMapViewModel {

    private static let maxLatitudeToShowStops = 0.02

    // MARK: - Publishers

    private let stateSubject = CurrentValueSubject<StopMapState, Never>(.loading)

    var state: AnyPublisher<StopMapState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    private let fabStateSubject = CurrentValueSubject<Bool, Never>(false)

    var fabState: AnyPublisher<Bool, Never> {
        return fabStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private let stopService: StopService

    private let locationService: LocationService

    private weak var eventCoordinator: StopMapEventCoordinator?

    private var cancellables: [AnyCancellable] = []

    private var locationStatusCancellable: AnyCancellable?

    // MARK: - Initialization

    init(stopService: StopService,
         locationService: LocationService,
         eventCoordinator: StopMapEventCoordinator) {
        self.stopService = stopService
        self.locationService = locationService
        self.eventCoordinator = eventCoordinator
        setupObservers()
    }

    // MARK: - Setup

    private func setupObservers() {
        locationService.observeLastLocationBounds()
            .map { locationBounds in StopMapState.setLocationBounds(locationBounds) }
            .replaceError(with: .error("Can't find last location"))
            .receive(on: RunLoop.main)
            .subscribe(stateSubject)
            .store(in: &cancellables)

        locationStatusCancellable = locationService.observeCurrentLocationPermissionStatus()
            .receive(on: RunLoop.main)
            .sink { [unowned self] status in
                switch status {
                case .granted:
                    self.fabStateSubject.value = true
                case .denied:
                    self.fabStateSubject.value = false
                }
            }
    }

    // MARK: - Intent Handling

    func handleIntent(_ intent: StopMapIntent) {
        switch intent {
        case .mapLocationMoved(let locationBounds):
            self.handleMoveMapLocationBoundsIntent(locationBounds: locationBounds)
        case .stopSelected(let stop):
            self.eventCoordinator?.stopSelectedInStopMap(stop)
        }
    }

    private func handleMoveMapLocationBoundsIntent(locationBounds: LocationBounds) {
        cancellables.removeAll()

        // Save the location, so we can restore it
        locationService.saveLastLocationBounds(locationBounds)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { _ in

            })
            .store(in: &cancellables)

        if abs(locationBounds.west - locationBounds.east) >= StopMapViewModel.maxLatitudeToShowStops {
            // If the map is too far zoomed out, we don't display any stops
            stateSubject.value = .setLocationBoundsWithStops(locationBounds, [])
        } else {
            stopService.observeStopsInLocationBounds(locationBounds)
                .map { stops in StopMapState.setLocationBoundsWithStops(locationBounds, stops) }
                .catch { error in Just(StopMapState.error(error.localizedDescription)) }
                .subscribe(stateSubject)
                .store(in: &cancellables)
        }
    }
}
