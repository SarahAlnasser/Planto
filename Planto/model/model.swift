//
//  model.swift
//  plants🍀
//
//  Created by Sarah Alnasser on 25/10/2025.
//
import SwiftUI
struct Plant: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var room: Room
    var light: Light
    var wateringDays: WateringDays
    var water: Water
    var isWatered: Bool = false

    var lastWateredAt: Date? = nil

    var isWateredToday: Bool {
        guard let d = lastWateredAt else { return false }
        return Calendar.current.isDateInToday(d)
    }
}

enum Room: String, CaseIterable, Identifiable, Codable {
    case bedroom, livingRoom, kitchen, balcony, bathroom
    var id: String { rawValue }
    var title: String {
        switch self {
        case .bedroom: return "Bedroom"
        case .livingRoom: return "Living Room"
        case .kitchen: return "Kitchen"
        case .balcony: return "Balcony"
        case .bathroom: return "Bathroom"
        }
    }
}

enum Light: String, CaseIterable, Identifiable, Codable {
    case fullSun, partialSun, lowLight
    var id: String { rawValue }
    var title: String {
        switch self {
        case .fullSun: return "Full Sun"
        case .partialSun: return "Partial Sun"
        case .lowLight: return "Low Light"
        }
    }
}

enum WateringDays: String, CaseIterable, Identifiable, Codable {
    case everyDay, every2Days, every3Days, onceAWeek, every10Days, every2Weeks
    var id: String { rawValue }
    var title: String {
        switch self {
        case .everyDay: return "Every day"
        case .every2Days: return "Every 2 days"
        case .every3Days: return "Every 3 days"
        case .onceAWeek: return "Once a week"
        case .every10Days: return "Every 10 days"
        case .every2Weeks: return "Every 2 weeks"
        }
    }
    var intervalDays: Int {
        switch self {
        case .everyDay:    return 1
        case .every2Days:  return 2
        case .every3Days:  return 3
        case .onceAWeek:   return 7
        case .every10Days: return 10
        case .every2Weeks: return 14
        }
    }
}

enum Water: String, CaseIterable, Identifiable, Codable {
    case ml20to50, ml50to100, ml100to200, ml200to300
    var id: String { rawValue }
    var title: String {
        switch self {
        case .ml20to50: return "20–50 ml"
        case .ml50to100: return "50–100 ml"
        case .ml100to200: return "100–200 ml"
        case .ml200to300: return "200–300 ml"
        }
    }
}
