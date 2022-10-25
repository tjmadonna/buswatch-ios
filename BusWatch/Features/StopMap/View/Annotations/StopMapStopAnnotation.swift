//
//  StopMapStopAnnotation.swift
//  BusWatch
//
//  Created by Tyler Madonna on 4/13/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import Foundation
import MapKit

final class StopMapStopAnnotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: stopMarker.coordinate.latitude,
                                      longitude: stopMarker.coordinate.longitude)
    }

    var title: String? {
        return stopMarker.title
    }

    var subtitle: String? {
        return stopMarker.routes.joined(separator: ", ")
    }

    let stopMarker: StopMarker

    init(stopMarker: StopMarker) {
        self.stopMarker = stopMarker
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
