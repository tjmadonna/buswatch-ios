//
//  AppCoordinator.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/24/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

final class AppNavigationViewController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.navBarColor
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
    }
}

final class AppCoordinator {

    // MARK: - Properties

    private let window: UIWindow

    private let appComponent = AppComponent()

    private let navigationController: UINavigationController = {
        return AppNavigationViewController()
    }()

    // MARK: - Initialization

    init(window: UIWindow) {
        self.window = window
        self.window.rootViewController = navigationController
    }

    func presentOverviewViewController() {
        do {
            let stopDataStore = try appComponent.stopLocalDataStore()
            let locationDataStore = try appComponent.locationLocalDataStore()
            let viewModel = OverviewViewModel(stopLocalDataStore: stopDataStore,
                                              locationLocalDataStore: locationDataStore,
                                              appCoordinator: self)
            let viewController = OverviewViewController(viewModel: viewModel)
            navigationController.pushViewController(viewController, animated: false)
        } catch {
            navigationController.presentAlertViewControllerWithTitle("Application Failed",
                                                                     message: "An error occured while loading the application")
            print(error)
        }
    }

    func presentStopMapViewController() {
        do {
            let stopDataStore = try appComponent.stopLocalDataStore()
            let locationDataStore = try appComponent.locationLocalDataStore()
            let viewModel = StopMapViewModel(stopLocalDataStore: stopDataStore,
                                             locationLocalDataStore: locationDataStore,
                                             appCoordinator: self)
            let viewController = StopMapViewController(viewModel: viewModel)
            viewController.title = "Map"
            navigationController.pushViewController(viewController, animated: true)
        } catch {
            navigationController.presentAlertViewControllerWithTitle("Application Failed",
                                                                     message: "An error occured while loading the application")
            print(error)
        }
    }

    func presentPredictionsViewControllerForStop(_ stop: Stop) {
        do {
            let stopDataStore = try appComponent.stopLocalDataStore()
            let predictionDataStore = try appComponent.predictionRemoteDataStore()
            let viewModel = PredictionsViewModel(stop: stop,
                                                 stopLocalDataStore: stopDataStore,
                                                 predictionRemoteDataStore: predictionDataStore,
                                                 appCoordinator: self)
            let viewController = PredictionsViewController(viewModel: viewModel)
            viewController.title = stop.title
            navigationController.pushViewController(viewController, animated: true)
        } catch {
            navigationController.presentAlertViewControllerWithTitle("Application Failed",
                                                                     message: "An error occured while loading the application")
            print(error)
        }
    }
}
