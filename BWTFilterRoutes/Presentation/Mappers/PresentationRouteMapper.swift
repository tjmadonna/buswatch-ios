//
//  PresentationRouteMapper.swift
//  FilterRoutes
//
//  Created by Tyler Madonna on 12/19/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import Foundation

public final class PresentationRouteMapper {

    public init() {}

    func mapRouteArrayToPresentationRouteArray(_ routes: [Route]?) -> [PresentationRoute]? {
        guard let routes = routes else { return nil }

        let presentationRoutes = routes
            .sorted(by: { $0.id.compare($1.id) == .orderedAscending })
            .compactMap { self.mapRouteToPresentationRoute($0) }

        if presentationRoutes.isEmpty {
            return nil
        } else {
            return presentationRoutes
        }
    }

    func mapRouteToPresentationRoute(_ route: Route?) -> PresentationRoute? {
        guard let route = route else { return nil }

        return PresentationRoute(routeId: route.id, selected: !route.excluded)
    }
}
