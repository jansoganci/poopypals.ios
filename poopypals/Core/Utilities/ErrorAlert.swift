//
//  ErrorAlert.swift
//  PoopyPals
//
//  Error alert model for UI
//

import Foundation

struct ErrorAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

