//
//  UserRole.swift
//  FindMyFirefighter
//
//  Defines the two primary user roles in the app.
//

import Foundation

enum UserRole: String, CaseIterable, Identifiable {
    case firefighter = "Firefighter"
    case family      = "Family / Friend"

    var id: String { rawValue }
}
