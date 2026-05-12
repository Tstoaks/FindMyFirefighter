//
//  PeerNote.swift
//  FindMyFirefighter
//
//  A note left by a firefighter on a station for peer support and awareness.
//

import Foundation

struct PeerNote: Identifiable {
    let id: Int
    let stationId: Int
    let author: String
    let content: String
    let timestamp: Date
}
