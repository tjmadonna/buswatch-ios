//
//  StopMapStopAnnotation.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/13/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import MapKit

final class StopMapStopAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
    }

    var title: String? {
        return stop.title
    }

    var subtitle: String? {
        return stop.routes.joined(separator: ", ")
    }

    let stop: StopMapStop

    init(stop: StopMapStop) {
        self.stop = stop
        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let otherAnnotation = object as? StopMapStopAnnotation else { return false }
        return title == otherAnnotation.title &&
            subtitle == otherAnnotation.subtitle &&
            coordinate.latitude == otherAnnotation.coordinate.latitude &&
            coordinate.longitude == otherAnnotation.coordinate.longitude
    }
}
