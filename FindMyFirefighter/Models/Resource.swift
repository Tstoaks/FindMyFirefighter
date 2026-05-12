//
//  Resource.swift
//  FindMyFirefighter
//
//  A resource (crew, engine, team) that can be assigned to an incident.
//

import Foundation

struct Resource: Identifiable {
    let id: String
    let name: String
    let type: ResourceType
    let assignedIncident: String?
    let incidentLocation: String?
    let status: ResourceStatus
    let lastUpdated: Date
}

enum ResourceType: String, CaseIterable {
    case crew   = "Crew"
    case engine = "Engine"
    case team   = "Team"
}

enum ResourceStatus: String, CaseIterable {
    case assigned   = "Assigned"
    case available  = "Available"
    case outOfService = "Out of Service"
    case enRoute    = "En Route"
}
