import SwiftUI

@main
struct CheckMateApp: App {
    @State private var dataStore = VCDataStore()
    @State private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dataStore)
                .environment(locationManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    locationManager.requestAccess()
                }
        }
    }
}
