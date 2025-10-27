//
//  viewModel.swift
//  plants🍀
//
//  Created by Sarah Alnasser on 26/10/2025.
//
import SwiftUI
import Combine

@MainActor
final class PlantStore: ObservableObject {
    @Published var plants: [Plant] = [] {
        didSet { save() }
    }
    init() {
        load()
        refreshDailyState()
    }

    //CRUD
    func add(_ plant: Plant) {
        plants.append(plant)
    }
    func update(_ plant: Plant) {
        guard let i = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[i] = plant
    }
    // Remove by index set (for swipe-to-delete in the list).
    func remove(at offsets: IndexSet) {
        plants.remove(atOffsets: offsets)
    }
    // Remove by id (for the "Delete Reminder" button in the edit sheet).
    func remove(id: UUID) {
        if let i = plants.firstIndex(where: { $0.id == id }) {
            plants.remove(at: i)
        }
    }

    // MARK: - checkmark & daily logic
    func toggleWatered(for plantID: UUID) {
        guard let i = plants.firstIndex(where: { $0.id == plantID }) else { return }
        if plants[i].isWateredToday {
            plants[i].isWatered = false
            plants[i].lastWateredAt = nil
        } else {
            plants[i].isWatered = true
            plants[i].lastWateredAt = Date()
        }
    }
    
    func refreshDailyState() {
        for i in plants.indices {
            // If the stored boolean says "checked" but it's no longer today, clear it.
            if plants[i].isWatered && !plants[i].isWateredToday {
                plants[i].isWatered = false
            }
        }
    }

    // MARK: - for TodayReminder

    var completedCount: Int {
        plants.filter { $0.isWateredToday }.count
    }
    var progressValue: Double {
        guard !plants.isEmpty else { return 0 }
        return Double(completedCount) / Double(plants.count)
    }
    var statusLine: String {
        let n = completedCount
        return n == 0
        ? "Your plants are waiting for a sip 💦"
        : "\(n) of your plants feel loved today ✨"
    }
    var isAllDone: Bool {
        !plants.isEmpty && completedCount == plants.count
    }

    // MARK: - Simple Persistence (JSON on disk)
    // Keeps things beginner-friendly and avoids external deps.

    private var saveURL: URL {
        let fm = FileManager.default
        let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("plants.json")
    }

    private func load() {
        let url = saveURL
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Plant].self, from: data)
            self.plants = decoded
        } catch {
            // If loading fails, start clean (don’t crash the app).
            self.plants = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(plants)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            // Silently ignore save errors for now (keep it simple).
        }
    }
}

