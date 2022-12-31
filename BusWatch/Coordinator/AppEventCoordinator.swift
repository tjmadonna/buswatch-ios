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
        appearance.backgroundColor = Resources.Colors.appBlack
        appearance.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        appearance.largeTitleTextAttributes = [ .foregroundColor: UIColor.white ]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white

        view.backgroundColor = .systemGroupedBackground
    }

}

final class AppEventCoordinator {

    // MARK: - Properties

    private let window: UIWindow

    private var appComponent: AppComponent!

    private let navigationController: UINavigationController = {
        return AppNavigationViewController()
    }()

    // MARK: - Initialization

    init(window: UIWindow) {
        self.window = window
        do {
            self.appComponent = try AppComponent()
            self.window.rootViewController = navigationController
        } catch {
            self.window.rootViewController = UIViewController()
        }
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

    func presentPredictionsViewControllerForStop(_ stop: PredictionsStop) {
        let predictionsComponent = PredictionsComponent()
        let viewControlller = predictionsComponent.providePredictionsViewController(appComponent,
                                                                                    eventCoordinator: self,
                                                                                    stop: stop)
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

    func presentSettingsViewConntroller() {
        let viewController = SettingsViewController()
        let navController = AppNavigationViewController(rootViewController: viewController)
        navigationController.present(navController, animated: true, completion: nil)
    }

}

extension AppEventCoordinator: OverviewEventCoordinator {

    func favoriteStopSelectedInOverview(_ stop: OverviewFavoriteStop) {
        let predictionsStop = PredictionsStop(id: stop.id, title: stop.title, serviceType: stop.serviceType)
        presentPredictionsViewControllerForStop(predictionsStop)
    }

    func stopMapSelectedInOverview() {
        presentStopMapViewController()
    }

    func settingsSelectedInOverview() {
        presentSettingsViewConntroller()
    }

}

extension AppEventCoordinator: StopMapEventCoordinator {

    func stopMarkerSelectedInStopMap(_ stopMarker: StopMarker) {
        let predictionsStop = PredictionsStop(id: stopMarker.id, title: stopMarker.title, serviceType: stopMarker.serviceType)
        presentPredictionsViewControllerForStop(predictionsStop)
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
