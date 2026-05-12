//
//  Incident.swift
//  FindMyFirefighter
//
//  Represents an active wildfire incident.
//

import Foundation
import CoreLocation

struct Incident: Identifiable {
    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let fireSize: String
    let containmentPercent: Int
    let managingAgency: String
    let lastUpdated: Date
    let assignedResources: [String]

    /// Simulated fire perimeter polygon around the incident center.
    var perimeterCoords: [CLLocationCoordinate2D] {
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        // Rough radius in degrees (~0.02 ≈ 1.4 miles) scaled by fire size category
        let r: Double = containmentPercent < 50 ? 0.035 : 0.02
        let sides = 12
        return (0..<sides).map { i in
            let angle = Double(i) * (2 * .pi / Double(sides))
            // Add slight randomness via a simple deterministic wobble
            let wobble = 1.0 + 0.15 * sin(Double(i) * 3.7 + Double(id))
            return CLLocationCoordinate2D(
                latitude: lat + r * wobble * cos(angle),
                longitude: lon + r * wobble * sin(angle) * 1.3
            )
        }
    }
}
