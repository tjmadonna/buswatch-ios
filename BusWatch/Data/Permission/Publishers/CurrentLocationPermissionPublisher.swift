//
//  CurrentLocationPermissionPublisher.swift
//  BusWatch
//
//  Created by Tyler Madonna on 3/26/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

struct CurrentLocationPermissionPublisher: Publisher {

    typealias Output = CurrentLocationPermissionStatus

    typealias Failure = Never

    private let locationManager: CLLocationManager

    init(locationManager: CLLocationManager) {
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
            let authorizationStatus: CLAuthorizationStatus
            if #available(iOS 14, *) {
                authorizationStatus = locationManager.authorizationStatus
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }

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

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            sendCurrentLocationPermissionStatus()
        }
    }
}
