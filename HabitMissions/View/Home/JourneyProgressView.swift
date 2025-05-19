//
//  JourneyProgressView.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import SwiftUI

struct JourneyProgressView: View {
    let currentFuel: Double // 0 to 100
    
    private let planetPositions = [0.1, 0.4, 0.7, 1.0] // Positions along the journey (0-1)
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                // Journey path
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [AppColors.spaceGray.opacity(0.3), AppColors.spaceGray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                // Progress bar
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [AppColors.sunsetOrange, AppColors.starYellow]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: progressWidth, height: 8)
                    .cornerRadius(4)
                
                // Planets
                ForEach(0..<planetPositions.count, id: \.self) { index in
                    ZStack {
                        Circle()
                            .fill(isPlanetReached(index) ? AppColors.starYellow : AppColors.spaceGray)
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: isPlanetReached(index) ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(isPlanetReached(index) ? AppColors.spaceBlue : .gray)
                    }
                    .offset(x: (UIScreen.main.bounds.width - 70) * CGFloat(planetPositions[index]) - 10)
                }
                
                // Rocket
                Image(systemName: "airplane")
                    .font(.system(size: 20))
                    .rotationEffect(Angle(degrees: 90))
                    .foregroundColor(AppColors.starYellow)
                    .offset(x: progressWidth - 10, y: 0)
            }
            .padding(.horizontal, 20)
            
            Text("Next Planet: Nebula-7")
                .font(.caption)
                .foregroundColor(AppColors.starYellow)
        }
        .padding(.vertical, 8)
    }
    
    private var progressWidth: CGFloat {
        return (UIScreen.main.bounds.width - 70) * CGFloat(currentFuel / 100)
    }
    
    private func isPlanetReached(_ index: Int) -> Bool {
        return (currentFuel / 100) >= planetPositions[index]
    }
}