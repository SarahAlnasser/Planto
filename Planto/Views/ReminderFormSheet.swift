//
//  ReminderFormSheet.swift
//  plants🍀
//
//  Created by Sarah Alnasser on 26/10/2025.
//
import SwiftUI

enum SheetMode {
    case add
    case edit
}

struct ReminderFormSheet: View {
    var mode: SheetMode
    //MARK: - Binding
    @Binding var plantName: String
    @Binding var room: Room
    @Binding var light: Light
    @Binding var wateringDays: WateringDays
    @Binding var water: Water
    
    // callbacks
    var onSave: (Plant) -> Void
    var onDelete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss // Access the environment's dismiss action to close the sheet
    
    @State private var showValidationAlert = false
    // Checks if plant name is filled
    var canSave: Bool {
        return !plantName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    //MARK: - Body
    var body: some View {
        VStack {
            HStack(spacing: 80) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 32)
                }
                .buttonStyle(.glass)

                Text("Set Reminder")
                    .font(.system(size: 17, weight: .bold))

                Button(action: {
                    if canSave {
                        let newPlant = Plant(
                            name: plantName,
                            room: room,
                            light: light,
                            wateringDays: wateringDays,
                            water: water
                        )
                        onSave(newPlant)

                        // 🔔 Schedule a simple local notification 5s after tapping ✓
                        Notification.shared.scheduleIn(
                            seconds: 5,
                            title: "Planto",
                            body: "Hey! let's water your plant"
                        )

                        dismiss()
                    } else {
                        showValidationAlert = true
                    }
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 32)
                }
                .buttonStyle(.glassProminent)
                .tint(.greenbutton)
                .disabled(!canSave) // Disable the button when form is invalid
            }
            .padding(.top, 10)

            //MARK: - Form
            Form {
                Section {
                    LabeledContent("Plant Name") {
                        TextField("Pothos", text: $plantName)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done) // Show "Done" on the keyboard
                    }
                }

                Section {
                    LabeledContent {
                        Picker("", selection: $room) {
                            ForEach(Room.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        Label("Room", systemImage: "location")
                            .symbolRenderingMode(.monochrome)
                            .foregroundColor(.white)
                    }

                    LabeledContent {
                        Picker("", selection: $light) {
                            ForEach(Light.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        Label("Light", systemImage: "sun.max")
                            .symbolRenderingMode(.monochrome)
                            .foregroundColor(.white)
                    }
                }

                Section {
                    LabeledContent {
                        Picker("", selection: $wateringDays) {
                            ForEach(WateringDays.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        Label("Watering Days", systemImage: "drop")
                            .symbolRenderingMode(.monochrome)
                            .foregroundColor(.white)
                    }

                    LabeledContent {
                        Picker("", selection: $water) {
                            ForEach(Water.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        Label("Water", systemImage: "drop")
                            .symbolRenderingMode(.monochrome)
                            .foregroundColor(.white)
                    }
                }

                if mode == .edit {
                    Button(role: .destructive) {
                        onDelete?()
                        dismiss()
                    } label: {
                        Text("Delete Reminder")
                            .foregroundColor(Color.delete)
                            .frame(width: 400)
                    }
                }
            }
        }
        //Alert if name empty
        .alert("Please enter a plant name.", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        }
        .presentationDetents([.large])
    }
}
