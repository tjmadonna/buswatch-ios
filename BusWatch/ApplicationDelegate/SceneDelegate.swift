//
//  SceneDelegate.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/6/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties

    var appEventCoordinator: AppEventCoordinator?

    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        self.window = window

        appEventCoordinator = AppEventCoordinator(window: window)
        appEventCoordinator?.presentOverviewViewController()
    }
}
