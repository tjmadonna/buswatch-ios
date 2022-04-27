//
//  AppEventCoordinator.swift
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

    func presentPredictionsViewControllerForStop(_ stopId: String, serviceType: ServiceType) {
        let predictionsComponent = PredictionsComponent()
        let viewControlller = predictionsComponent.providePredictionsViewController(appComponent,
                                                                                    eventCoordinator: self,
                                                                                    stopId: stopId,
                                                                                    serviceType: serviceType)
        navigationController.pushViewController(viewControlller, animated: true)
    }

    func presentFilterRoutesViewControllerForStop(_ stopId: String) {
        let filterRoutesComponent = FilterRoutesComponent()
        let viewControlller = filterRoutesComponent.provideFilterRoutesViewController(appComponent,
                                                                                      eventCoordinator: self,
                                                                                      stopId: stopId)
        let navController = AppNavigationViewController(rootViewController: viewControlller)
        navigationController.present(navController, animated: true, completion: nil)
    }
}

extension AppEventCoordinator: OverviewEventCoordinator {

    func favoriteStopSelectedInOverview(_ stop: FavoriteStop) {
        presentPredictionsViewControllerForStop(stop.id, serviceType: stop.serviceType)
    }

    func stopMapSelectedInOverview() {
        presentStopMapViewController()
    }
}

extension AppEventCoordinator: StopMapEventCoordinator {

    func stopSelectedInStopMap(_ stop: DetailedStop) {
        presentPredictionsViewControllerForStop(stop.id, serviceType: stop.serviceType)
    }
}

extension AppEventCoordinator: PredictionsEventCoordinator {

    func filterRoutesSelectedInFilterRoutes(_ stopId: String) {
        presentFilterRoutesViewControllerForStop(stopId)
    }
}

extension AppEventCoordinator: FilterRoutesEventCoordinator {

    func saveSelectedInFilterRoutes() {
        navigationController.topViewController?.dismiss(animated: true, completion: nil)
    }

    func cancelSelectedInFilterRoutes() {
        navigationController.topViewController?.dismiss(animated: true, completion: nil)
    }
}
