//
//  FrequencySelectionView.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import SwiftUI

struct FrequencySelectionView: View {
    @Binding var selectedDays: [Weekday]
    
    private let weekdays = Weekday.allCases
    private let weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        List {
            Button(action: {
                if selectedDays.count == weekdays.count {
                    // Deselect all
                    selectedDays = []
                } else {
                    // Select all
                    selectedDays = Weekday.allCases
                }
            }) {
                HStack {
                    Text(selectedDays.count == weekdays.count ? "Deselect All" : "Select All")
                    Spacer()
                    if selectedDays.count == weekdays.count {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            ForEach(weekdays, id: \.rawValue) { day in
                Button(action: {
                    if selectedDays.contains(day) {
                        selectedDays.removeAll { $0 == day }
                    } else {
                        selectedDays.append(day)
                    }
                }) {
                    HStack {
                        Text(weekdayNames[day.rawValue - 1])
                        Spacer()
                        if selectedDays.contains(day) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Days")
    }
}