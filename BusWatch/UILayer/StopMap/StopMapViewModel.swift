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

    private static let MaxLatitudeToShowStops = 0.02

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

    private let stopLocalDataStore: StopLocalDataStore

    private let locationLocalDataStore: LocationLocalDataStore

    private weak var appCoordinator: AppCoordinator?

    private var cancellables: [AnyCancellable] = []

    private var locationStatusCancellable: AnyCancellable?

    // MARK: - Initialization

    init(stopLocalDataStore: StopLocalDataStore, locationLocalDataStore: LocationLocalDataStore, appCoordinator: AppCoordinator) {
        self.stopLocalDataStore = stopLocalDataStore
        self.locationLocalDataStore = locationLocalDataStore
        self.appCoordinator = appCoordinator
        setupObservers()
    }

    // MARK: - Setup

    private func setupObservers() {
        locationLocalDataStore.getLastLocationBounds()
            .map { locationBounds in StopMapState.setLocationBounds(locationBounds) }
            .replaceError(with: .error("Can't find last location"))
            .receive(on: RunLoop.main)
            .subscribe(stateSubject)
            .store(in: &cancellables)

        locationStatusCancellable = locationLocalDataStore.getCurrentLocationPermissionStatus()
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
        case .moveMapLocationBounds(let locationBounds):
            self.handleMoveMapLocationBoundsIntent(locationBounds: locationBounds)
        case .showPredictionsForStop(let stop):
            self.appCoordinator?.presentPredictionsViewControllerForStop(stop)
        }
    }

    private func handleMoveMapLocationBoundsIntent(locationBounds: LocationBounds) {
        cancellables.removeAll()

        // Save the location, so we can restore it
        locationLocalDataStore.saveLastLocationBounds(locationBounds)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // TODO: handle error
                    print(error)
                }
            }, receiveValue: { _ in

            })
            .store(in: &cancellables)

        if (abs(locationBounds.west - locationBounds.east) >= StopMapViewModel.MaxLatitudeToShowStops) {
            // If the map is too far zoomed out, we don't display any stops
            stateSubject.value = .setLocationBoundsWithStops(locationBounds, [])
        } else {
            stopLocalDataStore.getStopsInLocationBounds(locationBounds)
                .map { stops in StopMapState.setLocationBoundsWithStops(locationBounds, stops) }
                .catch { error in Just(StopMapState.error(error.localizedDescription)) }
                .subscribe(stateSubject)
                .store(in: &cancellables)
        }
    }
}
