//
//  ContentView.swift
//  FindMyFirefighter
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var store = AppStore()

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            FireMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            FamilyTrackingView()
                .tabItem {
                    Label("Family", systemImage: "person.2.fill")
                }
            ResourceLookupView()
                .tabItem {
                    Label("Lookup", systemImage: "magnifyingglass")
                }
            StationsListView()
                .tabItem {
                    Label("Stations", systemImage: "building.2.fill")
                }
        }
        .tint(.red)
        .environment(store)
    }
}

// MARK: - Tracked Family Members

/// A firefighter being tracked by a family member / friend.
struct TrackedFirefighter: Identifiable, Hashable {
    let id: Int
    let name: String
    let relationship: String     // e.g. "Spouse", "Sibling", "Parent"
    let stationId: Int           // station they are assigned to
    let role: String             // e.g. "Engineer", "Captain", "Crew"
    let phone: String
    let lastCheckIn: Date
    let currentIncidentId: Int?  // nil if not on an incident
}

enum FirefighterSafetyStatus: String {
    case onScene  = "On Scene"
    case enRoute  = "En Route"
    case atStation = "At Station"
    case offDuty  = "Off Duty"

    var color: Color {
        switch self {
        case .onScene:   return .red
        case .enRoute:   return .orange
        case .atStation: return .green
        case .offDuty:   return .gray
        }
    }
}

extension TrackedFirefighter {
    func safetyStatus(stations: [Station]) -> FirefighterSafetyStatus {
        let station = stations.first { $0.id == stationId }
        if currentIncidentId != nil {
            return station?.status == .responding ? .enRoute : .onScene
        }
        switch station?.status {
        case .responding: return .enRoute
        case .onCall, .available: return .atStation
        default: return .offDuty
        }
    }
}

// MARK: - Incident Comment Feed

struct IncidentComment: Identifiable, Hashable {
    let id: UUID
    let incidentId: Int
    let author: String
    let role: String        // e.g. "Captain · LPF-12"
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(),
         incidentId: Int,
         author: String,
         role: String,
         content: String,
         timestamp: Date = Date()) {
        self.id = id
        self.incidentId = incidentId
        self.author = author
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - App Store (shared state)

@Observable
final class AppStore {
    var comments: [IncidentComment] = MockData.incidentComments
    var trackedFirefighters: [TrackedFirefighter] = MockData.trackedFirefighters

    /// Identity of the firefighter currently composing a comment.
    /// In a production app this would come from auth.
    var currentUserName: String = "You"
    var currentUserRole: String = "Firefighter · ANF-05"

    func comments(for incidentId: Int) -> [IncidentComment] {
        comments
            .filter { $0.incidentId == incidentId }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func addComment(to incidentId: Int, content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        comments.append(
            IncidentComment(
                incidentId: incidentId,
                author: currentUserName,
                role: currentUserRole,
                content: trimmed
            )
        )
    }
}

// MARK: - Fire Map

struct FireMapView: View {
    @Environment(AppStore.self) private var store
    let incidents = MockData.incidents
    let stations = MockData.stations
    @State private var selectedIncident: Incident?
    @State private var feedIncident: Incident?

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.5, longitude: -119.0),
            span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    // Fire perimeters
                    ForEach(incidents) { incident in
                        MapPolygon(coordinates: incident.perimeterCoords)
                            .foregroundStyle(
                                incident.containmentPercent < 50
                                    ? Color.red.opacity(0.3)
                                    : Color.orange.opacity(0.25)
                            )
                            .stroke(
                                incident.containmentPercent < 50 ? .red : .orange,
                                lineWidth: 2
                            )
                    }

                    // Incident center annotations
                    ForEach(incidents) { incident in
                        Annotation(incident.name, coordinate: incident.coordinate) {
                            Button {
                                selectedIncident = incident
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.title2)
                                        .foregroundStyle(incident.containmentPercent < 50 ? .red : .orange)
                                    Text(incident.name)
                                        .font(.caption2.bold())
                                        .foregroundStyle(.primary)
                                }
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Station annotations
                    ForEach(stations) { station in
                        Annotation(station.name, coordinate: station.coordinate) {
                            Image(systemName: "building.2.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .padding(4)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                }
                .mapStyle(.hybrid(elevation: .realistic))

                // Selected incident detail card
                if let incident = selectedIncident {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(incident.name)
                                .font(.headline)
                            Spacer()
                            Button {
                                selectedIncident = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        HStack {
                            Label(incident.fireSize, systemImage: "flame")
                            Spacer()
                            Text("\(incident.containmentPercent)% contained")
                        }
                        .font(.subheadline)

                        Text(incident.managingAgency)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(incident.assignedResources.count) resources assigned")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Button {
                                feedIncident = incident
                            } label: {
                                Label(
                                    "View Feed (\(store.comments(for: incident.id).count))",
                                    systemImage: "bubble.left.and.bubble.right.fill"
                                )
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                }
            }
            .navigationTitle("Fire Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $feedIncident) { incident in
                IncidentFeedView(incident: incident)
            }
        }
    }
}

// MARK: - Dashboard / Home

struct DashboardView: View {
    let incidents = MockData.incidents
    let stations = MockData.stations

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        VStack(alignment: .leading) {
                            Text("FindMyFirefighter")
                                .font(.title.bold())
                            Text("California — \(incidents.count) active incidents")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    // Active Incidents
                    Text("Active Incidents")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(incidents) { incident in
                        NavigationLink {
                            IncidentFeedView(incident: incident)
                        } label: {
                            IncidentCard(incident: incident)
                        }
                        .buttonStyle(.plain)
                    }

                    // Station Status Summary
                    Text("Station Status")
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(stations) { station in
                            StationStatusCard(station: station)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Incident Card

struct IncidentCard: View {
    let incident: Incident

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(incident.containmentPercent < 50 ? .red : .orange)
                    .frame(width: 10, height: 10)
                Text(incident.name)
                    .font(.headline)
                Spacer()
                Text("\(incident.containmentPercent)% contained")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label(incident.fireSize, systemImage: "flame")
                Spacer()
                Label(incident.managingAgency, systemImage: "building.columns")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("\(incident.assignedResources.count) resources assigned")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Station Status Card

struct StationStatusCard: View {
    let station: Station

    var statusColor: Color {
        switch station.status {
        case .onCall:     return .yellow
        case .responding: return .red
        case .available:  return .green
        case .offDuty:    return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(station.status.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(station.name)
                .font(.caption.bold())
                .lineLimit(2)
            Text(station.coverageArea)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Resource Lookup

struct ResourceLookupView: View {
    @State private var searchText = ""
    let resources = MockData.resources

    var filtered: [Resource] {
        if searchText.isEmpty { return resources }
        return resources.filter {
            $0.id.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { resource in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(resource.name)
                            .font(.headline)
                        Spacer()
                        Text(resource.status.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(resourceStatusColor(resource.status).opacity(0.2))
                            .foregroundStyle(resourceStatusColor(resource.status))
                            .clipShape(Capsule())
                    }
                    Text("ID: \(resource.id)  •  \(resource.type.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let incident = resource.assignedIncident {
                        Label(incident, systemImage: "flame")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    if let location = resource.incidentLocation {
                        Label(location, systemImage: "mappin")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .searchable(text: $searchText, prompt: "Crew name or engine ID")
            .navigationTitle("Resource Lookup")
        }
    }

    func resourceStatusColor(_ status: ResourceStatus) -> Color {
        switch status {
        case .assigned:    return .orange
        case .available:   return .green
        case .outOfService: return .gray
        case .enRoute:     return .blue
        }
    }
}

// MARK: - Stations List

struct StationsListView: View {
    let stations = MockData.stations

    var body: some View {
        NavigationStack {
            List(stations) { station in
                NavigationLink {
                    StationDetailView(station: station)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(station.name)
                                .font(.headline)
                            Text(station.coverageArea)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(station.status.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(stationColor(station.status).opacity(0.2))
                            .foregroundStyle(stationColor(station.status))
                            .clipShape(Capsule())
                    }
                }
            }
            .navigationTitle("Stations")
        }
    }

    func stationColor(_ status: StationStatus) -> Color {
        switch status {
        case .onCall:     return .yellow
        case .responding: return .red
        case .available:  return .green
        case .offDuty:    return .gray
        }
    }
}

// MARK: - Station Detail

struct StationDetailView: View {
    let station: Station
    var notes: [PeerNote] {
        MockData.peerNotes.filter { $0.stationId == station.id }
    }

    var body: some View {
        List {
            Section("Info") {
                LabeledContent("Unit Code", value: station.unitCode)
                LabeledContent("Coverage", value: station.coverageArea)
                LabeledContent("Status", value: station.status.rawValue)
            }

            Section("Personnel") {
                ForEach(station.assignedPersonnel, id: \.self) { name in
                    Label(name, systemImage: "person.fill")
                }
            }

            Section("Peer Notes") {
                if notes.isEmpty {
                    Text("No notes yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(notes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(note.author)
                                    .font(.caption.bold())
                                Spacer()
                                Text(note.timestamp, style: .relative)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text(note.content)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle(station.name)
    }
}

#Preview {
    ContentView()
}

// MARK: - Family Tracking

struct FamilyTrackingView: View {
    @Environment(AppStore.self) private var store
    private let stations = MockData.stations
    private let incidents = MockData.incidents

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                        VStack(alignment: .leading) {
                            Text("Tracked Family Members")
                                .font(.headline)
                            Text("Stay updated on your loved ones in the field")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("On Active Incident") {
                    let active = store.trackedFirefighters.filter { $0.currentIncidentId != nil }
                    if active.isEmpty {
                        Text("No tracked members currently on an incident.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(active) { ff in
                            NavigationLink {
                                TrackedFirefighterDetailView(firefighter: ff)
                            } label: {
                                TrackedFirefighterRow(
                                    firefighter: ff,
                                    stations: stations,
                                    incidents: incidents
                                )
                            }
                        }
                    }
                }

                Section("All Tracked") {
                    ForEach(store.trackedFirefighters.filter { $0.currentIncidentId == nil }) { ff in
                        NavigationLink {
                            TrackedFirefighterDetailView(firefighter: ff)
                        } label: {
                            TrackedFirefighterRow(
                                firefighter: ff,
                                stations: stations,
                                incidents: incidents
                            )
                        }
                    }
                }
            }
            .navigationTitle("Family")
        }
    }
}

private struct TrackedFirefighterRow: View {
    let firefighter: TrackedFirefighter
    let stations: [Station]
    let incidents: [Incident]

    private var status: FirefighterSafetyStatus {
        firefighter.safetyStatus(stations: stations)
    }

    private var stationName: String {
        stations.first { $0.id == firefighter.stationId }?.name ?? "—"
    }

    private var incidentName: String? {
        guard let id = firefighter.currentIncidentId else { return nil }
        return incidents.first { $0.id == id }?.name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(firefighter.name)
                        .font(.headline)
                    Text("\(firefighter.relationship) · \(firefighter.role)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(status.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(status.color.opacity(0.18))
                    .foregroundStyle(status.color)
                    .clipShape(Capsule())
            }

            Label(stationName, systemImage: "building.2.fill")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let incidentName {
                Label(incidentName, systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            HStack {
                Image(systemName: "clock")
                Text("Last check-in ")
                + Text(firefighter.lastCheckIn, style: .relative)
                + Text(" ago")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct TrackedFirefighterDetailView: View {
    @Environment(AppStore.self) private var store
    let firefighter: TrackedFirefighter
    private let stations = MockData.stations
    private let incidents = MockData.incidents

    private var station: Station? {
        stations.first { $0.id == firefighter.stationId }
    }

    private var currentIncident: Incident? {
        guard let id = firefighter.currentIncidentId else { return nil }
        return incidents.first { $0.id == id }
    }

    private var status: FirefighterSafetyStatus {
        firefighter.safetyStatus(stations: stations)
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(.red)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firefighter.name)
                            .font(.title3.bold())
                        Text(firefighter.role)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(status.rawValue)
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(status.color.opacity(0.18))
                            .foregroundStyle(status.color)
                            .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Contact") {
                LabeledContent("Relationship", value: firefighter.relationship)
                LabeledContent("Phone", value: firefighter.phone)
                LabeledContent(
                    "Last check-in",
                    value: firefighter.lastCheckIn.formatted(date: .abbreviated, time: .shortened)
                )
            }

            if let station {
                Section("Station") {
                    LabeledContent("Name", value: station.name)
                    LabeledContent("Unit", value: station.unitCode)
                    LabeledContent("Coverage", value: station.coverageArea)
                    LabeledContent("Status", value: station.status.rawValue)
                }
            }

            if let currentIncident {
                Section("Current Incident") {
                    NavigationLink {
                        IncidentFeedView(incident: currentIncident)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentIncident.name)
                                .font(.headline)
                            Text("\(currentIncident.fireSize) · \(currentIncident.containmentPercent)% contained")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Label(
                                "Open incident feed",
                                systemImage: "bubble.left.and.bubble.right"
                            )
                            .font(.caption.bold())
                            .foregroundStyle(.red)
                            .padding(.top, 2)
                        }
                    }
                }
            }
        }
        .navigationTitle(firefighter.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Incident Feed

struct IncidentFeedView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let incident: Incident

    @State private var draft: String = ""
    @FocusState private var composerFocused: Bool

    private var comments: [IncidentComment] {
        store.comments(for: incident.id)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Incident summary header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(incident.containmentPercent < 50 ? .red : .orange)
                        Text(incident.name)
                            .font(.headline)
                        Spacer()
                        Text("\(incident.containmentPercent)% contained")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("\(incident.fireSize) · \(incident.managingAgency)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)

                Divider()

                if comments.isEmpty {
                    ContentUnavailableView(
                        "No comments yet",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Be the first to share a status update for this incident.")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(comments) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                    .listStyle(.plain)
                }

                Divider()

                // Composer
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Add an update…", text: $draft, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .focused($composerFocused)

                    Button {
                        store.addComment(to: incident.id, content: draft)
                        draft = ""
                        composerFocused = false
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                            .padding(10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Incident Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct CommentRow: View {
    let comment: IncidentComment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.author)
                    .font(.subheadline.bold())
                Text("· \(comment.role)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(comment.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(comment.content)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}
