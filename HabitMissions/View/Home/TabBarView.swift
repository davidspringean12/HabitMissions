import SwiftUI

enum Tab: Int {
    case home = 0
    case astroAI = 1
    case journey = 2
    case missions = 3
    case profile = 4
}

struct TabBarView: View {
    @Binding var selectedTab: Int
    @Namespace private var namespace
    
    var body: some View {
        HStack {
            ForEach(0..<5) { tab in
                tabButton(tab: Tab(rawValue: tab)!)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.spaceDark)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func tabButton(tab: Tab) -> some View {
        Button {
            withAnimation(.spring()) {
                selectedTab = tab.rawValue
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab.rawValue {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.cosmicPurple)
                            .frame(width: 44, height: 44)
                            .matchedGeometryEffect(id: "tab_background", in: namespace)
                    }
                    
                    Image(systemName: iconName(for: tab))
                        .font(.system(size: 20))
                        .foregroundColor(
                            selectedTab == tab.rawValue ? .white : .gray
                        )
                }
                
                Text(title(for: tab))
                    .font(.system(size: 10))
                    .foregroundColor(
                        selectedTab == tab.rawValue ? AppColors.starYellow : .gray
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func iconName(for tab: Tab) -> String {
        switch tab {
        case .home:
            return "house.fill"
        case .astroAI:
            return "sparkles"
        case .journey:
            return "globe"
        case .missions:
            return "checklist"
        case .profile:
            return "person.fill"
        }
    }
    
    private func title(for tab: Tab) -> String {
        switch tab {
        case .home:
            return "Today"
        case .astroAI:
            return "AstroAI"
        case .journey:
            return "Journey"
        case .missions:
            return "Missions"
        case .profile:
            return "Captain"
        }
    }
}
