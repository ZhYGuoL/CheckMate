import MapKit
import SwiftUI

struct MapScreen: View {
    @Environment(VCDataStore.self) private var dataStore
    @Environment(LocationManager.self) private var locationManager

    /// Neighborhood zoom when tapping the center-on-user button.
    private static let userZoomSpan = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
    private static let bayAreaRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.45, longitude: -122.15),
        span: MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
    )

    @State private var cameraPosition: MapCameraPosition = .region(bayAreaRegion)
    @State private var selectedOrganization: VCOrganization?
    @State private var filter: VCCategory?

    private var filteredOrganizations: [VCOrganization] {
        guard let filter else { return dataStore.organizations }
        return dataStore.organizations.filter { $0.category == filter }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapLayer

                VStack(spacing: 12) {
                    headerCard
                    if let loadError = dataStore.loadError {
                        Text(loadError)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.accentSecondary)
                            .padding(.horizontal, 4)
                    }
                    filterBar
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        CenterOnUserButton(
                            isEnabled: locationManager.userLocation != nil,
                            action: centerOnUser
                        )
                        .padding(.trailing, 16)
                        .padding(.bottom, 28)
                    }
                }
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                locationManager.requestAccess()
            }
            .sheet(item: $selectedOrganization) { organization in
                OrganizationDetailSheet(organization: organization)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition, selection: $selectedOrganization) {
            if let userCoordinate = locationManager.userLocation?.coordinate {
                Annotation("You", coordinate: userCoordinate) {
                    UserLocationMarker()
                }
            }

            ForEach(filteredOrganizations) { organization in
                Annotation(organization.name, coordinate: organization.coordinate) {
                    MapPinView(organization: organization, isSelected: selectedOrganization?.id == organization.id)
                }
                .tag(organization)
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func centerOnUser() {
        guard let location = locationManager.userLocation else {
            locationManager.requestAccess()
            return
        }

        withAnimation(.easeInOut(duration: 0.45)) {
            cameraPosition = .region(
                MKCoordinateRegion(center: location.coordinate, span: Self.userZoomSpan)
            )
        }
    }

    private var headerCard: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bay Area Capital")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text("\(filteredOrganizations.count) top VCs & accelerators")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
            }

            Spacer()

            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(AppTheme.accent)
                .symbolRenderingMode(.hierarchical)
        }
        .padding(18)
        .glassCard()
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: "All", isSelected: filter == nil) {
                    filter = nil
                }

                ForEach(VCCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.label,
                        isSelected: filter == category,
                        tint: AppTheme.categoryColor(category)
                    ) {
                        filter = category
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

private struct UserLocationMarker: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(AppTheme.accent, lineWidth: 3)
                .background(Circle().fill(AppTheme.accent.opacity(0.2)))
                .frame(width: 48, height: 48)
                .scaleEffect(pulse ? 1.12 : 0.92)
                .opacity(pulse ? 0.55 : 0.9)

            Circle()
                .fill(Color.white)
                .frame(width: 26, height: 26)
                .shadow(color: .black.opacity(0.28), radius: 5, y: 2)

            Circle()
                .fill(AppTheme.accent.gradient)
                .frame(width: 18, height: 18)

            Image(systemName: "location.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

private struct BouncyCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.86 : 1)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.52), value: configuration.isPressed)
    }
}

private struct CenterOnUserButton: View {
    let isEnabled: Bool
    let action: () -> Void

    @State private var tapCount = 0
    @State private var showRipple = false

    var body: some View {
        Button {
            guard isEnabled else { return }
            tapCount += 1
            showRipple = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showRipple = false
            }
        } label: {
            ZStack {
                if isEnabled {
                    Circle()
                        .strokeBorder(AppTheme.accent.opacity(0.7), lineWidth: 2.5)
                        .frame(width: 48, height: 48)
                        .scaleEffect(showRipple ? 1.45 : 1)
                        .opacity(showRipple ? 0 : 0.85)
                        .animation(.easeOut(duration: 0.4), value: showRipple)
                }

                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isEnabled ? Color.black.opacity(0.85) : Color.white.opacity(0.4))
                    .frame(width: 48, height: 48)
                    .background(
                        isEnabled ? AppTheme.accent : Color.white.opacity(0.12),
                        in: Circle()
                    )
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(isEnabled ? 0.35 : 0.15), lineWidth: 1)
                    }
                    .shadow(
                        color: AppTheme.accent.opacity(isEnabled ? (showRipple ? 0.65 : 0.4) : 0),
                        radius: showRipple ? 16 : 10,
                        y: 3
                    )
            }
        }
        .buttonStyle(BouncyCircleButtonStyle())
        .disabled(!isEnabled)
        .sensoryFeedback(.impact(weight: .medium), trigger: tapCount)
        .accessibilityLabel("Center map on your location")
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var tint: Color = AppTheme.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? Color.black : .white)
                .background(isSelected ? tint : Color.white.opacity(0.10), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct MapPinView: View {
    let organization: VCOrganization
    let isSelected: Bool

    var body: some View {
        VCLogoView(
            organization: organization,
            size: isSelected ? 38 : 30,
            isSelected: isSelected
        )
    }
}

private struct OrganizationDetailSheet: View {
    let organization: VCOrganization

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("#\(organization.rank)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                    Text(organization.name)
                        .font(.title2.weight(.bold))
                    Text(organization.category.label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.categoryColor(organization.category))
                }
                Spacer()
                VCLogoView(organization: organization, size: 56, showsBorder: true)
            }

            Label(organization.address, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.backgroundGradient)
    }
}

#Preview {
    RootView()
        .environment(VCDataStore())
        .environment(LocationManager())
}
