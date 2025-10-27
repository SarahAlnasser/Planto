//
//  start.swift
//  plants🍀
//
//  Created by Sarah Alnasser on 26/10/2025.
//
import SwiftUI

struct start: View {
    @EnvironmentObject var store: PlantStore
    @State private var showForm = false
    @State private var goToTodayReminder = false
    
    @State private var plantName = ""
    @State private var room: Room = .bedroom
    @State private var light: Light = .fullSun
    @State private var wateringDays: WateringDays = .everyDay
    @State private var water: Water = .ml20to50

    private var canProceed: Bool {
        !plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
            ZStack(alignment: .center) {
                      Color.background.ignoresSafeArea()

                      VStack(spacing: 24) {
                          Spacer(minLength: 40)

                          Image("homeplant")
                              .resizable()
                              .scaledToFit()
                              .frame(width: 220, height: 220)

                          Text("Start your plant journey!")
                              .font(.system(size: 25, weight: .bold))
                              .foregroundColor(.white)
                              .multilineTextAlignment(.center)

                          Text("Now all your plants will be in one place and we will help you take care of them :)🪴")
                              .font(.system(size: 16))
                              .foregroundColor(.grayText)
                              .multilineTextAlignment(.center)
                              .padding(.horizontal, 20)

                          Spacer()
                          
                    Button(action: { showForm = true }) {
                        Text("Set Plant Reminder")
                            .font(.system(size: 17))
                            .foregroundColor(Color.mainText)
                            .frame(width: 280, height: 38)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.greenbutton)
                    .padding(.bottom, 100)
                }
                .padding()
            }
            .navigationDestination(isPresented: $goToTodayReminder) {
                TodayReminder()
            }
            .sheet(isPresented: $showForm) {
                ReminderFormSheet(
                    mode: .add,
                    plantName: $plantName,
                    room: $room,
                    light: $light,
                    wateringDays: $wateringDays,
                    water: $water,
                    onSave: { plant in
                        store.add(plant)
                        showForm = false
                        DispatchQueue.main.async { 
                                goToTodayReminder = true
                            }
                    }
                )
            }
        
    }
}

#Preview {
    NavigationStack {
        start()
    }
    .environmentObject(PlantStore())
}


