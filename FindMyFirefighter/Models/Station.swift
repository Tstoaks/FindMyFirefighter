//
//  Station.swift
//  FindMyFirefighter
//
//  Represents a fire station with its location and current status.
//

import Foundation
import CoreLocation

struct Station: Identifiable {
    let id: Int
    let name: String
    let unitCode: String
    let coordinate: CLLocationCoordinate2D
    let coverageArea: String
    let status: StationStatus
    let assignedPersonnel: [String]
}

enum StationStatus: String, CaseIterable {
    case onCall     = "On Call"
    case responding = "Responding"
    case available  = "Available"
    case offDuty    = "Off Duty"

    var color: String {
        switch self {
        case .onCall:     return "yellow"
        case .responding: return "red"
        case .available:  return "green"
        case .offDuty:    return "gray"
        }
    }
}
