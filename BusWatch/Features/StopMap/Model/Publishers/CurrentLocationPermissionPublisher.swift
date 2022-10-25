//
//  CurrentLocationPermissionPublisher.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Combine
import CoreLocation
import Foundation

enum CurrentLocationPermissionStatus {
    case granted
    case denied
}

struct CurrentLocationPermissionPublisher: Publisher {

    typealias Output = CurrentLocationPermissionStatus

    typealias Failure = Never

    private let locationManager: CLLocationManager

    init(locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
    }

    func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        subscriber.receive(subscription: Inner(downstream: subscriber, locationManager: locationManager))
    }

    private final class Inner<S>: NSObject, Subscription, CLLocationManagerDelegate
        where S: Subscriber, S.Input == Output, S.Failure == Failure {

        private let locationManager: CLLocationManager

        private var downstream: S?

        init(downstream: S, locationManager: CLLocationManager = CLLocationManager()) {
            self.downstream = downstream
            self.locationManager = locationManager
            super.init()
            self.locationManager.delegate = self
        }

        func request(_ demand: Subscribers.Demand) {
            sendCurrentLocationPermissionStatus()
        }

        func cancel() {
            downstream?.receive(completion: .finished)
            locationManager.delegate = nil
            downstream = nil
        }

        private func sendCurrentLocationPermissionStatus() {
            let status = getCurrentLocationPermissionStatus()
            _ = downstream?.receive(status)
        }

        private func getCurrentLocationPermissionStatus() -> CurrentLocationPermissionStatus {
            
            let authorizationStatus = locationManager.authorizationStatus

            switch authorizationStatus {
            case .authorizedWhenInUse:
                return .granted
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                return .denied
            default:
                locationManager.stopUpdatingLocation()
                return .denied
            }
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            sendCurrentLocationPermissionStatus()
        }

    }

}

