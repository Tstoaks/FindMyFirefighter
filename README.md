# FindMyFirefighter

> A SwiftUI iOS application that helps family members track firefighters deployed to active wildfire incidents in real time.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Screenshots & App Structure](#screenshots--app-structure)
- [Implementation](#implementation)
- [Code Organization](#code-organization)
- [How to Run the Project](#how-to-run-the-project)
- [Dependencies & Requirements](#dependencies--requirements)
- [Data Model](#data-model)
- [Known Limitations / Future Work](#known-limitations--future-work)

---

## Project Overview

**FindMyFirefighter** is a capstone iOS project built with SwiftUI. The app is designed for two audiences:

| User Type | Purpose |
|---|---|
| **Family / Friend** | Track a loved one deployed to a wildfire incident, view their last check-in, current assignment, and safety status |
| **Firefighter** | View active incidents on a live map, look up assigned resources, read peer notes at their station, and post updates to an incident feed |

The current build is a **proof-of-concept (POC)** that uses realistic California-based mock data (USFS fire stations, NIFC-style incidents, and simulated crew resources). The architecture is designed to swap in live data sources (NIFC InciWeb API, authenticated user profiles) without restructuring the app.

---

## Features

| Tab | Screen | What It Does |
|---|---|---|
| 🏠 Home | **Dashboard** | Lists active wildfire incidents with containment stats and a station status grid |
| 🗺️ Map | **Fire Map** | MapKit hybrid map showing fire perimeter polygons, incident pins, and station markers; tap any incident for a quick-info card with a link to the incident feed |
| 👥 Family | **Family Tracking** | Shows all tracked family members separated into "On Active Incident" and "Off Duty" sections; each row shows safety status, station, and last check-in time |
| 🔍 Lookup | **Resource Lookup** | Searchable list of crews, engines, and teams with live assignment status |
| 🏢 Stations | **Stations List → Detail** | Browse all stations; detail page shows personnel roster and peer notes left by station members |

Additional feature:
- **Incident Feed** – Per-incident threaded comment feed where firefighters can post situational updates; family members can read the feed from the tracked firefighter's detail screen

---

## Screenshots & App Structure

```
FindMyFirefighter (TabView)
├── DashboardView          — incident cards + station status grid
├── FireMapView            — MapKit hybrid map + perimeter polygons
│   └── IncidentFeedView   — threaded comment feed per incident
├── FamilyTrackingView     — tracked firefighter list
│   └── TrackedFirefighterDetailView — contact, station, and current incident
├── ResourceLookupView     — searchable resource list
└── StationsListView       — station browser
    └── StationDetailView  — roster + peer notes
```

---

## Implementation

### Technology Stack

| Technology | Role |
|---|---|
| **SwiftUI** | Entire UI layer — views, navigation, data binding |
| **MapKit** | Interactive map, `MapPolygon` fire perimeters, `Annotation` overlays |
| **CoreLocation** | `CLLocationCoordinate2D` for all geographic data |
| **Swift Observation (`@Observable`)** | Reactive shared app state via `AppStore` |

### Architecture

The app follows a lightweight **MVVM-adjacent** pattern:

- **Models** (`/Models`) — Plain Swift structs/enums representing domain objects (`Incident`, `Station`, `Resource`, `PeerNote`, `UserRole`).
- **AppStore** — A single `@Observable` class that acts as a shared state container injected via SwiftUI's `.environment()`. It holds mutable collections (comments, tracked firefighters) and exposes mutating methods (`addComment`).
- **Views** — All views live in `ContentView.swift` for this POC. They read from `MockData` or `AppStore` directly. No separate ViewModel files are needed at this scale.
- **MockData** — A `MockData` enum with static computed properties that seed every data type. Easy to replace with network calls.

### Key Design Decisions

1. **`@Observable` instead of `ObservableObject`** — Uses the newer Swift 5.9 `@Observable` macro, which eliminates the need for `@Published` and `@StateObject` boilerplate.
2. **Environment injection** — `AppStore` is passed down the view hierarchy with `.environment(store)`, keeping views decoupled from each other.
3. **Fire perimeter simulation** — `Incident.perimeterCoords` generates a 12-sided polygon with a deterministic wobble factor based on the incident ID to simulate a realistic irregular fire perimeter without needing GIS data.
4. **Safety status computed property** — `TrackedFirefighter.safetyStatus(stations:)` derives the display status by cross-referencing the firefighter's station status and current incident assignment, keeping the model logic out of the view layer.

---

## Code Organization

```
FindMyFirefighter/
└── FindMyFirefighter/               ← Main app target
    ├── FindMyFirefighterApp.swift   ← App entry point (@main)
    ├── ContentView.swift            ← All views + AppStore + shared types
    ├── Assets.xcassets/             ← App icons and accent color
    ├── Models/
    │   ├── Incident.swift           ← Wildfire incident model + perimeter logic
    │   ├── Station.swift            ← Fire station model + StationStatus enum
    │   ├── Resource.swift           ← Resource model (crew/engine/team)
    │   ├── PeerNote.swift           ← Station peer note model
    │   └── UserRole.swift           ← UserRole enum (Firefighter / Family)
    ├── MockData/
    │   └── MockData.swift           ← All sample data (stations, incidents, resources, notes)
    └── ViewModels/                  ← Reserved for future ViewModel classes
```

### File Descriptions

| File | Purpose |
|---|---|
| `FindMyFirefighterApp.swift` | App entry point; sets up the root `WindowGroup` with `ContentView` |
| `ContentView.swift` | Root `TabView` and all view structs; also contains `AppStore`, `TrackedFirefighter`, `FirefighterSafetyStatus`, and `IncidentComment` |
| `Incident.swift` | `Incident` struct with `id`, `name`, coordinates, fire size, containment %, managing agency, assigned resources, and `perimeterCoords` computed property |
| `Station.swift` | `Station` struct and `StationStatus` enum (Available, On Call, Responding, Off Duty) |
| `Resource.swift` | `Resource` struct, `ResourceType` enum (Crew/Engine/Team), `ResourceStatus` enum |
| `PeerNote.swift` | `PeerNote` struct — a timestamped note authored by a station member |
| `UserRole.swift` | `UserRole` enum defining the two user types |
| `MockData.swift` | Static mock data: 5 California USFS stations, 3 active incidents, 7 peer notes, 7 resources, 5 tracked firefighters, incident comments |

---

## How to Run the Project

### Requirements

- **Xcode 15** or later (Xcode 15.2+ recommended)
- **iOS 17.0** SDK or later (for `@Observable` macro support)
- macOS Ventura (13) or later
- An Apple Developer account is **not** required to run on the iOS Simulator

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Tstoaks/FindMyFirefighter.git
   cd FindMyFirefighter
   ```

2. **Open in Xcode**
   ```bash
   open FindMyFirefighter.xcodeproj
   ```

3. **Select a simulator target**
   - In the Xcode toolbar, choose any **iPhone** simulator running iOS 17+
   - Recommended: iPhone 15 Pro or iPhone 16

4. **Build and run**
   - Press `⌘R` or click the **Run** button
   - The app launches in the simulator with pre-loaded mock data

5. **Explore the app**
   - Navigate between tabs: Home, Map, Family, Lookup, Stations
   - Tap an incident on the map to view its info card and open the incident feed
   - Tap a station to see personnel and peer notes
   - Tap a tracked firefighter to see their detail view

> **No network connection is required.** All data is local mock data.

---

## Dependencies & Requirements

| Dependency | Source | Notes |
|---|---|---|
| SwiftUI | Apple SDK | Built-in, no installation needed |
| MapKit | Apple SDK | Built-in, no installation needed |
| CoreLocation | Apple SDK | Built-in, no installation needed |
| Swift Observation | Swift 5.9+ | Included with Xcode 15+ |

**No third-party packages or CocoaPods are required.**  
The project has zero external dependencies.

---

## Data Model

```
Incident
  ├── id: Int
  ├── name: String
  ├── coordinate: CLLocationCoordinate2D
  ├── fireSize: String
  ├── containmentPercent: Int
  ├── managingAgency: String
  ├── lastUpdated: Date
  ├── assignedResources: [String]
  └── perimeterCoords: [CLLocationCoordinate2D]  ← computed

Station
  ├── id: Int
  ├── name: String
  ├── unitCode: String
  ├── coordinate: CLLocationCoordinate2D
  ├── coverageArea: String
  ├── status: StationStatus
  └── assignedPersonnel: [String]

Resource
  ├── id: String
  ├── name: String
  ├── type: ResourceType       (Crew | Engine | Team)
  ├── assignedIncident: String?
  ├── incidentLocation: String?
  ├── status: ResourceStatus   (Assigned | Available | Out of Service | En Route)
  └── lastUpdated: Date

TrackedFirefighter
  ├── id: Int
  ├── name: String
  ├── relationship: String
  ├── stationId: Int
  ├── role: String
  ├── phone: String
  ├── lastCheckIn: Date
  └── currentIncidentId: Int?

PeerNote
  ├── id: Int
  ├── stationId: Int
  ├── author: String
  ├── content: String
  └── timestamp: Date

IncidentComment
  ├── id: UUID
  ├── incidentId: Int
  ├── author: String
  ├── role: String
  ├── content: String
  └── timestamp: Date
```

---

## Known Limitations / Future Work

| Limitation | Future Enhancement |
|---|---|
| All data is hardcoded mock data | Integrate NIFC InciWeb API and USFS data feeds for live incident updates |
| No user authentication | Add Sign in with Apple + role-based profiles (firefighter vs. family) |
| Location tracking is simulated | Use `CoreLocation` to broadcast real GPS positions to a backend |
| No push notifications | Add APNs push notifications when a tracked firefighter's status changes |
| Views all in one file | Refactor into separate SwiftUI view files per screen |
| No persistence | Add SwiftData or Core Data for offline caching and note storage |

---

*Built as a capstone project — FindMyFirefighter — Spring 2026*
