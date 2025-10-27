//
//  TodayReminder.swift
//  plants🍀
//
//  Created by Sarah Alnasser on 26/10/2025.
//

import SwiftUI

// MARK: - TodayReminder

struct TodayReminder: View {
    // The source of truth (inject from App entry or parent view)
    @EnvironmentObject var store: PlantStore

    // Add sheet control + draft fields
    @State private var showAddSheet = false
    @State private var draftName = ""
    @State private var draftRoom: Room = .bedroom
    @State private var draftLight: Light = .fullSun
    @State private var draftDays: WateringDays = .everyDay
    @State private var draftWater: Water = .ml20to50

    // Edit sheet control (when user taps a plant name)
    @State private var editingPlant: Plant? = nil
    // Separate draft for editing so user can cancel without changing the live model
    @State private var editName = ""
    @State private var editRoom: Room = .bedroom
    @State private var editLight: Light = .fullSun
    @State private var editDays: WateringDays = .everyDay
    @State private var editWater: Water = .ml20to50

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background (replace with your custom color if you have one)
            Color(.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {

                // Title
                Text("My Plants 🌱")
                    .font(.largeTitle.bold())
                    .padding(.top, 8)

                Divider()
                    .background(Color.grayText)

                // ALL DONE STATE
                if store.isAllDone {
                    AllDoneView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    // Progress header
                    VStack(spacing: 12) {
                        Text(store.statusLine)
                            .font(.callout)
                            .foregroundColor(.mainText)
                            .multilineTextAlignment(.center)
                        ThickProgress(value: store.progressValue)
                            .frame(height: 8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 14)                    // The scrollable list of plants
                    List {
                        ForEach(store.plants) { plant in
                            PlantRow(
                                plant: plant,
                                onToggle: { store.toggleWatered(for: plant.id) },
                                onTapName: { beginEditing(plant) }
                            )
                        }
                        .onDelete(perform: store.remove)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .padding(.horizontal, 16)


            // Floating + button (always visible)
            Button {
                beginAdd()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 32)
            }
            .buttonStyle(.glassProminent)
            .tint(Color.greenbutton)
            .padding()
            .accessibilityLabel("Add plant")
        }

        // MARK: - ADD SHEET
        .sheet(isPresented: $showAddSheet) {
            ReminderFormSheet(
                mode: .add,
                plantName: $draftName,
                room: $draftRoom,
                light: $draftLight,
                wateringDays: $draftDays,
                water: $draftWater,
                onSave: { newPlant in
                    store.add(newPlant)           // add to list
                    // Optional: store.scheduleNotifications(for: newPlant)
                }
            )
        }

        // MARK: - EDIT SHEET
        .sheet(item: $editingPlant) { plant in
            ReminderFormSheet(
                mode: .edit,
                plantName: $editName,
                room: $editRoom,
                light: $editLight,
                wateringDays: $editDays,
                water: $editWater,
                onSave: { updated in
                    // Preserve ID and dates so we don't lose history
                    var copy = updated
                    copy.id = plant.id
                    copy.lastWateredAt = plant.lastWateredAt
                    copy.isWatered = plant.isWatered // or recompute from lastWateredAt if you prefer

                    store.update(copy)
                    // Optional: store.scheduleNotifications(for: copy)
                },
                onDelete: {
                    store.remove(id: plant.id)
                    // Optional: store.cancelNotifications(for: plant.id)
                }
            )
        }
        // Keep daily state correct when returning to foreground (optional)
        .onAppear { store.refreshDailyState() }
    }
    // MARK: - Helpers (draft management)

    private func beginAdd() {
        // Reset drafts to sensible defaults
        draftName = ""
        draftRoom = .bedroom
        draftLight = .fullSun
        draftDays = .everyDay
        draftWater = .ml20to50
        showAddSheet = true
    }

    private func beginEditing(_ plant: Plant) {
        editingPlant = plant
        // Fill drafts from the selected plant
        editName = plant.name
        editRoom = plant.room
        editLight = plant.light
        editDays = plant.wateringDays
        editWater = plant.water
    }
}

// MARK: - Row View

//One row in the list: leading checkmark, name (tap to edit), and small badges.
struct PlantRow: View {
    let plant: Plant
    let onToggle: () -> Void
    let onTapName: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Checkmark toggle
            Button(action: onToggle) {
                Image(systemName: plant.isWateredToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .foregroundColor(plant.isWatered ? .greenbutton : .doneTask)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {

                // ROOM LINE (above the name)
                HStack(spacing: 6) {
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(.grayText)
                    Text("in \(plant.room.title)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.grayText)
                }

                // NAME (tap to edit)
                Button(action: onTapName) {
                    Text(plant.name)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(plant.isWatered ? .grayText : .mainText)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)

                // TAGS: colored sun + water
                HStack(spacing: 8) {
                    LightTag(text: plant.light.title)   // yellow-ish
                    WaterTag(text: plant.water.title)   // blue-ish
                }
                .font(.caption)
            }

            Spacer()
        }
    }
}

// MARK: - Simple Tag Pill

struct LightTag: View {
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sun.max")
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.sheetBackground)
        )
        .foregroundColor(.text4Sun) // icon+text tint
    }
}

struct WaterTag: View {
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "drop")
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.sheetBackground)
        )
       
        .foregroundColor(.text4Water)
    }
}


// MARK: - Thick Progress (like your design)

struct ThickProgress: View {
    let value: Double   // expected 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.15))
                Capsule()
                    .fill(Color.greenbutton)
                    .frame(width: max(0, geo.size.width * value))
                    .animation(.easeInOut(duration: 0.35), value: value)
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}

// MARK: - All Done View

struct AllDoneView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("finishplant")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
            Text("All Done!🎉")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("All Reminders Completed")
                .font(.system(size: 16))
                .foregroundColor(.grayText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)

    }
}
