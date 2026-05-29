import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            MapScreen()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            CompassScreen()
                .tabItem {
                    Label("Compass", systemImage: "location.north.fill")
                }
        }
        .tint(AppTheme.accent)
    }
}
