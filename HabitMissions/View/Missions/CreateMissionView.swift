//
//  CreateMissionView.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import SwiftUI

struct CreateMissionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = CreateMissionViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mission Details")) {
                    TextField("Mission Name", text: $viewModel.name)
                    
                    Picker("Category", selection: $viewModel.category) {
                        ForEach(MissionCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Picker("Mission Type", selection: $viewModel.missionType) {
                        Text("Daily").tag(MissionType.daily)
                        Text("Weekly").tag(MissionType.weekly)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if viewModel.missionType == .daily {
                        NavigationLink(destination: FrequencySelectionView(selectedDays: $viewModel.frequency)) {
                            HStack {
                                Text("Frequency")
                                Spacer()
                                Text(viewModel.frequencyText)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Stepper("Goal per Day: \(viewModel.goalPerDay)", value: $viewModel.goalPerDay, in: 1...10)
                    
                    DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                }
                
                Section(header: Text("Reminders")) {
                    Toggle("Set Reminder", isOn: $viewModel.hasReminder)
                    
                    if viewModel.hasReminder {
                        DatePicker("Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.createMission { result in
                            switch result {
                            case .success:
                                presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                viewModel.errorMessage = error.localizedDescription
                                viewModel.showError = true
                            }
                        }
                    }) {
                        Text("Create Mission")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .navigationTitle("New Mission")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

extension MissionCategory: CaseIterable {
    public static var allCases: [MissionCategory] {
        return [.physicalTraining, .mentalPreparation, .skillDevelopment, .equipmentMaintenance]
    }
}