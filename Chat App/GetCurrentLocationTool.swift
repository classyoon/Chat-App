//
//  GetCurrentLocationTool.swift
//  Chat App
//
//  Created by Conner Yoon on 2/14/26.
//

import Foundation
import CoreLocation
import FoundationModels

struct GetCurrentLocationTool: Tool {
    let name = "getCurrentLocation"
    let description = "Gets the user's current city and location."

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> String {
        for try await update in CLLocationUpdate.liveUpdates() {
            guard let location = update.location else { continue }

            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            if let placemark = placemarks.first {
                var parts: [String] = []
                if let city = placemark.locality { parts.append(city) }
                if let state = placemark.administrativeArea { parts.append(state) }
                if let country = placemark.country { parts.append(country) }
                return parts.joined(separator: ", ")
            }

            return "Lat \(location.coordinate.latitude), Lon \(location.coordinate.longitude)"
        }

        return "Unable to determine location."
    }
}
