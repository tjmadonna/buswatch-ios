//
//  StopMapViewModel.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/11/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import MapKit

final class StopMapViewModel {

//    let span = MKCoordinateSpan(latitudeDelta: 0.018638820689957925, longitudeDelta: 0.01328327616849378)

    private static let maxLatitudeToShowStops = 0.020

    private static let maxLongitudeToShowStops = 0.015

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

    private let service: StopMapServiceConformable

    private weak var eventCoordinator: StopMapEventCoordinator?

    private var cancellables: [AnyCancellable] = []

    private var locationStatusCancellable: AnyCancellable?

    // MARK: - Initialization

    init(service: StopMapServiceConformable,
         eventCoordinator: StopMapEventCoordinator) {
        self.service = service
        self.eventCoordinator = eventCoordinator
        setupLastCoordinatorRegion()
        setupObservers()
    }

    // MARK: - Setup

    private func setupLastCoordinatorRegion() {
        let result = service.getLastCoordinateRegion()
        switch result {
        case .success(let coordinateRegion):
            stateSubject.value = .setInitialCoordinateRegion(coordinateRegion)
        case .failure(let error):
            print(error)
        }
    }

    private func setupObservers() {
        service.observeCurrentLocationPermission()
            .receive(on: RunLoop.main)
            .sink { [unowned self] status in
                switch status {
                case .granted:
                    self.fabStateSubject.value = true
                case .denied:
                    self.fabStateSubject.value = false
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Intent Handling

    func handleIntent(_ intent: StopMapIntent) {
        switch intent {
        case .coordinateRegionMoved(let coordinateRegion):
            handleCoordinateRegionMovedIntent(coordinateRegion)
        case .stopMarkerSelected(let stopMarker):
            eventCoordinator?.stopMarkerSelectedInStopMap(stopMarker)
        }
    }

    private func handleCoordinateRegionMovedIntent(_ coordinateRegion: MKCoordinateRegion) {
        if case .failure(let error) = service.updateLastCoordinateRegion(coordinateRegion) {
            print(error)
        }

        if abs(coordinateRegion.span.latitudeDelta) >= StopMapViewModel.maxLatitudeToShowStops &&
            abs(coordinateRegion.span.longitudeDelta) >= StopMapViewModel.maxLongitudeToShowStops {
            // If the map is too far zoomed out, we don't display any stops
            stateSubject.value = .setStopMarkers([])
        } else {
            Task.init { [unowned self] in
                let result = await self.service.getStopMarkersInCoordinateRegion(coordinateRegion)
                DispatchQueue.main.async {
                    switch result {
                    case .success(let markers):
                        self.stateSubject.value = .setStopMarkers(markers)
                    case .failure(let error):
                        self.stateSubject.value = .error(error.localizedDescription)
                    }
                }
            }
        }
    }
}
