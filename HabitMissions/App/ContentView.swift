//
//  ContentView.swift
//  HabitMissions
//
//  Created by David Springean on 15.05.25.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Your other main views here
            
            #if DEBUG
            NotificationTestView()
                .tabItem {
                    Label("Test Notifications", systemImage: "bell.badge")
                }
            #endif
        }
    }
}