//
//  MockData.swift
//  FindMyFirefighter
//
//  Sample data for the POC — California fire stations, incidents, and resources.
//

import Foundation
import CoreLocation

enum MockData {

    // MARK: - Stations (California)

    static let stations: [Station] = [
        Station(
            id: 1,
            name: "Los Padres Station 12",
            unitCode: "LPF-12",
            coordinate: CLLocationCoordinate2D(latitude: 34.7361, longitude: -119.7414),
            coverageArea: "Upper Santa Ynez",
            status: .onCall,
            assignedPersonnel: ["James", "Ian", "Maria"]
        ),
        Station(
            id: 2,
            name: "Angeles NF Station 5",
            unitCode: "ANF-05",
            coordinate: CLLocationCoordinate2D(latitude: 34.2517, longitude: -118.1542),
            coverageArea: "San Gabriel Mountains",
            status: .responding,
            assignedPersonnel: ["Carlos", "Priya"]
        ),
        Station(
            id: 3,
            name: "Cleveland NF Station 8",
            unitCode: "CNF-08",
            coordinate: CLLocationCoordinate2D(latitude: 33.5427, longitude: -117.4659),
            coverageArea: "Trabuco Canyon",
            status: .available,
            assignedPersonnel: ["Liam", "Sofia", "Jordan"]
        ),
        Station(
            id: 4,
            name: "Sequoia NF Station 3",
            unitCode: "SQF-03",
            coordinate: CLLocationCoordinate2D(latitude: 36.0652, longitude: -118.6717),
            coverageArea: "Kern River Valley",
            status: .onCall,
            assignedPersonnel: ["Derek", "Aisha"]
        ),
        Station(
            id: 5,
            name: "Shasta-Trinity Station 1",
            unitCode: "SHF-01",
            coordinate: CLLocationCoordinate2D(latitude: 40.8665, longitude: -122.3117),
            coverageArea: "Sacramento River Canyon",
            status: .available,
            assignedPersonnel: ["Tyler", "Jonah", "Ava"]
        ),
    ]

    // MARK: - Incidents

    static let incidents: [Incident] = [
        Incident(
            id: 101,
            name: "Figueroa Fire",
            coordinate: CLLocationCoordinate2D(latitude: 34.6872, longitude: -119.8034),
            fireSize: "1,200 acres",
            containmentPercent: 35,
            managingAgency: "USFS — Los Padres NF",
            lastUpdated: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
            assignedResources: ["LPF-12", "ANF-05", "BC11LPF"]
        ),
        Incident(
            id: 102,
            name: "Kern Canyon Fire",
            coordinate: CLLocationCoordinate2D(latitude: 35.9833, longitude: -118.5921),
            fireSize: "480 acres",
            containmentPercent: 60,
            managingAgency: "USFS — Sequoia NF",
            lastUpdated: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
            assignedResources: ["SQF-03", "BC51LPF"]
        ),
        Incident(
            id: 103,
            name: "Santiago Fire",
            coordinate: CLLocationCoordinate2D(latitude: 33.6891, longitude: -117.5723),
            fireSize: "320 acres",
            containmentPercent: 80,
            managingAgency: "USFS — Cleveland NF",
            lastUpdated: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
            assignedResources: ["CNF-08"]
        ),
    ]

    // MARK: - Peer Notes

    static let peerNotes: [PeerNote] = [
        PeerNote(id: 1, stationId: 1, author: "James",
                 content: "Road closure near main entrance — use south gate.",
                 timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!),
        PeerNote(id: 2, stationId: 1, author: "Ian",
                 content: "Hydrant on Oak St has low pressure — heads up.",
                 timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!),
        PeerNote(id: 3, stationId: 1, author: "Maria",
                 content: "Great work today team, stay safe out there 💪",
                 timestamp: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!),
        PeerNote(id: 4, stationId: 2, author: "Carlos",
                 content: "Steep terrain on north ridge — watch footing.",
                 timestamp: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!),
        PeerNote(id: 5, stationId: 3, author: "Sofia",
                 content: "Water tanker resupply available at Mile Marker 12.",
                 timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!),
        PeerNote(id: 6, stationId: 4, author: "Derek",
                 content: "Wind shift expected after 1400 — be ready.",
                 timestamp: Calendar.current.date(byAdding: .minute, value: -45, to: Date())!),
        PeerNote(id: 7, stationId: 5, author: "Tyler",
                 content: "All clear on north sector — no spot fires.",
                 timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!),
    ]

    // MARK: - Resources (for lookup)

    static let resources: [Resource] = [
        Resource(id: "BC11LPF", name: "LPF Batt. 11 MRD",   type: .engine,
                 assignedIncident: "Figueroa Fire",   incidentLocation: "Los Padres NF",
                 status: .assigned, lastUpdated: Date()),
        Resource(id: "BC12LPF", name: "LPF Batt. 12 MRD",   type: .engine,
                 assignedIncident: nil,               incidentLocation: nil,
                 status: .available, lastUpdated: Date()),
        Resource(id: "AFV02",   name: "Vandenberg CREW",     type: .crew,
                 assignedIncident: "Figueroa Fire",   incidentLocation: "Los Padres NF",
                 status: .assigned, lastUpdated: Date()),
        Resource(id: "BC51LPF", name: "LPF Batt. 51 ORD",   type: .engine,
                 assignedIncident: "Kern Canyon Fire", incidentLocation: "Sequoia NF",
                 status: .assigned, lastUpdated: Date()),
        Resource(id: "SHT01",   name: "Shasta Hotshots",     type: .crew,
                 assignedIncident: nil,               incidentLocation: nil,
                 status: .available, lastUpdated: Date()),
        Resource(id: "ANF03",   name: "Angeles Engine 3",    type: .engine,
                 assignedIncident: "Figueroa Fire",   incidentLocation: "Los Padres NF",
                 status: .enRoute, lastUpdated: Date()),
        Resource(id: "CNF-TF1", name: "Cleveland Task Force", type: .team,
                 assignedIncident: "Santiago Fire",   incidentLocation: "Cleveland NF",
                 status: .assigned, lastUpdated: Date()),
    ]

    // MARK: - Tracked Family Members

    static let trackedFirefighters: [TrackedFirefighter] = [
        TrackedFirefighter(
            id: 1,
            name: "James Carter",
            relationship: "Spouse",
            stationId: 1,
            role: "Engineer",
            phone: "(805) 555-0142",
            lastCheckIn: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!,
            currentIncidentId: 101
        ),
        TrackedFirefighter(
            id: 2,
            name: "Carlos Reyes",
            relationship: "Sibling",
            stationId: 2,
            role: "Captain",
            phone: "(626) 555-0188",
            lastCheckIn: Calendar.current.date(byAdding: .minute, value: -42, to: Date())!,
            currentIncidentId: 101
        ),
        TrackedFirefighter(
            id: 3,
            name: "Derek Lin",
            relationship: "Parent",
            stationId: 4,
            role: "Crew Boss",
            phone: "(559) 555-0117",
            lastCheckIn: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
            currentIncidentId: 102
        ),
        TrackedFirefighter(
            id: 4,
            name: "Sofia Alvarez",
            relationship: "Friend",
            stationId: 3,
            role: "Firefighter II",
            phone: "(949) 555-0163",
            lastCheckIn: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
            currentIncidentId: nil
        ),
        TrackedFirefighter(
            id: 5,
            name: "Tyler Brooks",
            relationship: "Sibling",
            stationId: 5,
            role: "Engineer",
            phone: "(530) 555-0109",
            lastCheckIn: Calendar.current.date(byAdding: .minute, value: -25, to: Date())!,
            currentIncidentId: nil
        ),
    ]

    // MARK: - Incident Comments (per-incident feed)

    static let incidentComments: [IncidentComment] = [
        IncidentComment(
            incidentId: 101,
            author: "James Carter",
            role: "Engineer · LPF-12",
            content: "Established anchor point on south flank. Holding line.",
            timestamp: Calendar.current.date(byAdding: .minute, value: -12, to: Date())!
        ),
        IncidentComment(
            incidentId: 101,
            author: "Carlos Reyes",
            role: "Captain · ANF-05",
            content: "Need additional water tender at staging — tanks running low.",
            timestamp: Calendar.current.date(byAdding: .minute, value: -28, to: Date())!
        ),
        IncidentComment(
            incidentId: 101,
            author: "Maria Chen",
            role: "Crew Lead · LPF-12",
            content: "Smoke column shifting NE — keep eyes on the ridge.",
            timestamp: Calendar.current.date(byAdding: .minute, value: -55, to: Date())!
        ),
        IncidentComment(
            incidentId: 102,
            author: "Derek Lin",
            role: "Crew Boss · SQF-03",
            content: "Containment improving on the east side. Mop-up in progress.",
            timestamp: Calendar.current.date(byAdding: .minute, value: -40, to: Date())!
        ),
        IncidentComment(
            incidentId: 102,
            author: "Aisha Khan",
            role: "Firefighter · SQF-03",
            content: "Watch for rolling debris near the drainage.",
            timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        ),
        IncidentComment(
            incidentId: 103,
            author: "Sofia Alvarez",
            role: "Firefighter II · CNF-08",
            content: "Heavy mop-up underway. No active flame visible from MM 12.",
            timestamp: Calendar.current.date(byAdding: .minute, value: -20, to: Date())!
        ),
    ]
}
