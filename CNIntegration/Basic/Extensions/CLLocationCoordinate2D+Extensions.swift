//
//  CLLocationCoordinate2D+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 05/11/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: CustomStringConvertible, Equatable {

    // MARK: Distance

    func distance(from fromCoordinate: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: fromCoordinate.latitude, longitude: fromCoordinate.longitude)
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: fromLocation)
    }

    // MARK: Printable

    public var description: String {
        return debugDescription
    }

    var debugDescription: String {
        return "{latittude '\(latitude)', longitude: '\(longitude)'}"
    }

    // MARK: Equatable

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D: Codable {

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
