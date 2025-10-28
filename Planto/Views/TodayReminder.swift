//
//  TodayReminder.swift
//  plants🍀
//
//  Created by Sarah Alnasser on 26/10/2025.
//

import SwiftUI

struct TodayReminder: View {
    @EnvironmentObject var store: PlantStore

    @State private var showAddSheet = false
    @State private var draftName = ""
    @State private var draftRoom: Room = .bedroom
    @State private var draftLight: Light = .fullSun
    @State private var draftDays: WateringDays = .everyDay
    @State private var draftWater: Water = .ml20to50

    @State private var editingPlant: Plant? = nil
    @State private var editName = ""
    @State private var editRoom: Room = .bedroom
    @State private var editLight: Light = .fullSun
    @State private var editDays: WateringDays = .everyDay
    @State private var editWater: Water = .ml20to50
// MARK: - body
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.background).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {

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
                    .padding(.top, 14)
                    
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
                    store.add(newPlant)
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
                    var copy = updated
                    copy.id = plant.id
                    copy.lastWateredAt = plant.lastWateredAt
                    copy.isWatered = plant.isWatered

                    store.update(copy)
                },
                onDelete: {
                    store.remove(id: plant.id)
                }
            )
        }
        .onAppear { store.refreshDailyState() }
    }
    // MARK: - Helpers

    private func beginAdd() {
        draftName = ""
        draftRoom = .bedroom
        draftLight = .fullSun
        draftDays = .everyDay
        draftWater = .ml20to50
        showAddSheet = true
    }

    private func beginEditing(_ plant: Plant) {
        editingPlant = plant
        editName = plant.name
        editRoom = plant.room
        editLight = plant.light
        editDays = plant.wateringDays
        editWater = plant.water
    }
}

// MARK: - Row View

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

                HStack(spacing: 6) {
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(.grayText)
                    Text("in \(plant.room.title)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.grayText)
                }

                Button(action: onTapName) {
                    Text(plant.name)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(plant.isWatered ? .grayText : .mainText)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)

                HStack(spacing: 8) {
                    LightTag(text: plant.light.title)
                    WaterTag(text: plant.water.title)
                }
                .font(.caption)
            }

            Spacer()
        }
    }
}

// MARK: - Tag Pill

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
        .foregroundColor(.text4Sun)
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


// MARK: - Progress

struct ThickProgress: View {
    let value: Double

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

// MARK: - All Done

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
