//
//  PredictionsBarItemHandler.swift
//  BWTPredictions
//
//  Created by Tyler Madonna on 12/23/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit
import MapKit

protocol PredictionsNavBarHandlerDelegate: AnyObject {

    func predictionsNavBarHandlerDidSelectFavoriteStop(_ predictionsNavBarHandler: PredictionsNavBarHandler)

    func predictionsNavBarHandlerDidSelectFilterRoutes(_ predictionsNavBarHandler: PredictionsNavBarHandler)

    func predictionsNavBarHandler(_ predictionsNavBarHandler: PredictionsNavBarHandler,
                                  wantsToPresentAlertController alertController: UIAlertController)
}

final class PredictionsNavBarHandler {

    // MARK: - Views

    private let titleView: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    private let navigationItem: UINavigationItem

    private var state: PredictionsNavBarState = PredictionsNavBarState(favorited: false, title: "")

    weak var delegate: PredictionsNavBarHandlerDelegate?

    init(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        navigationItem.titleView = titleView
    }

    func setTitleForNavBarState(_ state: PredictionsNavBarState) {
        titleView.text = state.title
    }

    func setBarItemsForNavBarState(_ state: PredictionsNavBarState) {
        self.state = state
        if #available(iOS 14.0, *) {
            let barButtonMenu = UIMenu(title: "", children: [
                UIAction(title: state.favorited ? "Unfavorite Stop" : "Favorite Stop",
                         image: UIImage(systemName: "star"),
                         handler: handleFavoriteToggleTouch),
                UIAction(title: "Filter Routes",
                         image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
                         handler: handleFilterRoutesTouch)
            ])
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "",
                                                                image: UIImage(systemName: "ellipsis.circle"),
                                                                menu: barButtonMenu)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(handlePre14EllipsisBarItemTouch))
        }
    }

    @objc private func handleFavoriteToggleTouch(target: Any) {
        delegate?.predictionsNavBarHandlerDidSelectFavoriteStop(self)
    }

    @objc private func handleFilterRoutesTouch(target: Any) {
        delegate?.predictionsNavBarHandlerDidSelectFilterRoutes(self)
    }

    @objc private func handlePre14EllipsisBarItemTouch(favorited: Bool) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelActionButton)

        let favoriteActionTitle = state.favorited ? "Unfavorite Stop" : "Favorite Stop"
        let favoriteActionButton = UIAlertAction(title: favoriteActionTitle, style: .default) { _ in
            self.handleFavoriteToggleTouch(target: 1)
        }
        alertController.addAction(favoriteActionButton)

        let filterActionButton = UIAlertAction(title: "Filter Routes", style: .default) { _ in
            self.handleFilterRoutesTouch(target: 2)
        }
        alertController.addAction(filterActionButton)

        delegate?.predictionsNavBarHandler(self, wantsToPresentAlertController: alertController)
    }
}
