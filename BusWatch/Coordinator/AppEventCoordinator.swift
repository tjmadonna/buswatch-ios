//
//  AppEventCoordinator.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/24/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit
import Overview
import StopMap
import Predictions

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

final class AppEventCoordinator {

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
        let overviewComponent = OverviewComponent()
        let viewController = overviewComponent.provideOverviewViewController(appComponent, eventCoordinator: self)
        navigationController.pushViewController(viewController, animated: false)
    }

    func presentStopMapViewController() {
        let stopMapComponent = StopMapComponent()
        let viewControlller = stopMapComponent.provideStopMapViewController(appComponent, eventCoordinator: self)
        navigationController.pushViewController(viewControlller, animated: true)
    }

    func presentPredictionsViewControllerForStop(_ stopId: String) {
        let predictionsComponent = PredictionsComponent()
        let viewControlller = predictionsComponent.providePredictionsViewController(appComponent,
                                                                                    eventCoordinator: self,
                                                                                    stopId: stopId)
        navigationController.pushViewController(viewControlller, animated: true)
    }
}

extension AppEventCoordinator: OverviewEventCoordinator {

    func favoriteStopSelectedInOverview(_ stopId: String) {
        presentPredictionsViewControllerForStop(stopId)
    }

    func stopMapSelectedInOverview() {
        presentStopMapViewController()
    }
}

extension AppEventCoordinator: StopMapEventCoordinator {

    func stopSelectedInStopMap(_ stopId: String) {
        presentPredictionsViewControllerForStop(stopId)
    }
}

extension AppEventCoordinator: PredictionsEventCoordinator {

}
