import SwiftUI

struct HeaderView: View {
    var streakCount: Int = 0
    var planetsCount: Int = 0
    var fuelPercentage: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateString)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Welcome, Captain!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.starYellow, AppColors.sunsetOrange]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
            }
            
            // Quick stats
            HStack(spacing: 16) {
                statView(value: "\(streakCount)", label: "Day Streak", icon: "flame.fill", color: AppColors.sunsetOrange)
                statView(value: "\(planetsCount)", label: "Planets", icon: "globe", color: AppColors.cosmicPurple)
                statView(value: "\(Int(fuelPercentage))%", label: "Fuel", icon: "bolt.fill", color: AppColors.starYellow)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    private func statView(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(AppColors.spaceGray.opacity(0.5))
        .cornerRadius(12)
    }
}
