//
//  MKCoordinateRegion+Utils.swift
//  BusWatch
//
//  Created by Tyler Madonna on 10/24/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import MapKit

extension MKCoordinateRegion: Codable {

    enum CodingKeys: String, CodingKey {
        case centerLatitude
        case centerLongitude
        case latitudeDelta
        case longitudeDelta
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let centerLatitude = try values.decode(Double.self, forKey: .centerLatitude)
        let centerLongitude = try values.decode(Double.self, forKey: .centerLongitude)
        let latitudeDelta = try values.decode(Double.self, forKey: .latitudeDelta)
        let longitudeDelta = try values.decode(Double.self, forKey: .longitudeDelta)

        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        self.init(center: center, span: span)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.center.latitude, forKey: .centerLatitude)
        try container.encode(self.center.longitude, forKey: .centerLongitude)
        try container.encode(self.span.latitudeDelta, forKey: .latitudeDelta)
        try container.encode(self.span.longitudeDelta, forKey: .longitudeDelta)
    }

}

extension MKCoordinateRegion: Equatable {

    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
            lhs.center.longitude == rhs.center.longitude &&
            lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
            lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }

}
