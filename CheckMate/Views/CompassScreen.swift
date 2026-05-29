import CoreLocation
import SwiftUI

struct CompassScreen: View {
    @Environment(VCDataStore.self) private var dataStore
    @Environment(LocationManager.self) private var locationManager

    private var nearestOrganization: VCOrganization? {
        guard let userLocation = locationManager.userLocation else { return nil }
        return dataStore.nearest(to: userLocation)
    }

    private var distanceText: String? {
        guard
            let userLocation = locationManager.userLocation,
            let nearestOrganization
        else { return nil }
        return GeoHelpers.formattedDistance(
            GeoHelpers.distance(from: userLocation, to: nearestOrganization.location)
        )
    }

    private var bearingDegrees: Double? {
        guard
            let userLocation = locationManager.userLocation,
            let nearestOrganization
        else { return nil }
        return GeoHelpers.bearing(
            from: userLocation.coordinate,
            to: nearestOrganization.coordinate
        )
    }

    private var deviceHeading: Double {
        guard let heading = locationManager.heading else { return 0 }
        let value = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
        return value >= 0 ? value : 0
    }

    /// Rotates the dial so "N" stays aligned with true north as you turn.
    private var dialRotation: Double {
        -deviceHeading
    }

    private var needleRotation: Double {
        guard let bearingDegrees else { return 0 }
        return bearingDegrees - deviceHeading
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()

                RadialGradient(
                    colors: [AppTheme.accent.opacity(0.18), .clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 320
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    header

                    CompassDialView(dialRotation: dialRotation, needleRotation: needleRotation)
                        .frame(maxWidth: 340, maxHeight: 340)
                        .padding(.vertical, 8)

                    targetCard

                    if let errorMessage = locationManager.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.accentSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .navigationBarHidden(true)
            .onAppear {
                locationManager.requestAccess()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Nearest Capital")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
            Text("Hold your phone flat and follow the green needle")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var targetCard: some View {
        if let loadError = dataStore.loadError {
            statusCard(
                title: "Could not load firms",
                message: loadError,
                systemImage: "exclamationmark.triangle.fill"
            )
        } else if dataStore.organizations.isEmpty {
            statusCard(
                title: "No firm data",
                message: "vc_locations.json is missing from the app bundle. Clean build and run again.",
                systemImage: "doc.badge.exclamationmark"
            )
        } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
            statusCard(
                title: "Location access needed",
                message: locationManager.errorMessage ?? "Turn on location for CheckMate in Settings.",
                systemImage: "location.slash.fill"
            )
        } else if locationManager.authorizationStatus == .notDetermined {
            statusCard(
                title: "Allow location access",
                message: "CheckMate needs your location to find the nearest VC or accelerator.",
                systemImage: "location.fill",
                showsProgress: true
            )
        } else if let nearestOrganization, let distanceText, let bearingDegrees {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 14) {
                    VCLogoView(organization: nearestOrganization, size: 54)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("#\(nearestOrganization.rank)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.accent)
                            Spacer()
                            Text(distanceText)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)
                        }

                        Text(nearestOrganization.name)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                HStack(spacing: 16) {
                    Label(nearestOrganization.category.label, systemImage: nearestOrganization.category.symbolName)
                    Label(GeoHelpers.formattedBearing(bearingDegrees), systemImage: "safari")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.subtleText)

                Text(nearestOrganization.address)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.subtleText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
        } else {
            statusCard(
                title: "Finding your location",
                message: "Waiting for GPS fix. On the simulator, set a location under Features → Location.",
                systemImage: "location.fill",
                showsProgress: true
            )
        }
    }

    private func statusCard(
        title: String,
        message: String,
        systemImage: String,
        showsProgress: Bool = false
    ) -> some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(AppTheme.accent)

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            if showsProgress {
                ProgressView()
                    .tint(AppTheme.accent)
            }

            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

private struct CompassDialView: View {
    let dialRotation: Double
    let needleRotation: Double

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                .background(Circle().fill(Color.white.opacity(0.04)))

            compassRose
                .rotationEffect(.degrees(dialRotation))
                .animation(.spring(response: 0.35, dampingFraction: 0.78), value: dialRotation)

            CompassNeedle()
                .rotationEffect(.degrees(needleRotation))
                .animation(.spring(response: 0.35, dampingFraction: 0.78), value: needleRotation)

            Circle()
                .fill(AppTheme.accent.gradient)
                .frame(width: 18, height: 18)
                .overlay {
                    Circle()
                        .strokeBorder(Color.black.opacity(0.25), lineWidth: 1)
                }
                .shadow(color: AppTheme.accent.opacity(0.45), radius: 10)
        }
        .padding(24)
        .glassCard(cornerRadius: 999)
    }

    private var compassRose: some View {
        ZStack {
            ForEach(0..<72, id: \.self) { tick in
                Rectangle()
                    .fill(tick.isMultiple(of: 9) ? Color.white.opacity(0.55) : Color.white.opacity(0.18))
                    .frame(width: tick.isMultiple(of: 9) ? 2 : 1, height: tick.isMultiple(of: 9) ? 16 : 8)
                    .offset(y: -132)
                    .rotationEffect(.degrees(Double(tick) * 5))
            }

            ForEach(cardinalMarkers, id: \.label) { marker in
                Text(marker.label)
                    .font(marker.label == "N" ? .caption.weight(.bold) : .caption2.weight(.semibold))
                    .foregroundStyle(marker.label == "N" ? AppTheme.accent : AppTheme.subtleText)
                    .offset(y: -108)
                    .rotationEffect(.degrees(marker.degrees))
            }
        }
    }

    private var cardinalMarkers: [(label: String, degrees: Double)] {
        [
            ("N", 0),
            ("E", 90),
            ("S", 180),
            ("W", 270),
        ]
    }
}

private struct CompassNeedle: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(AppTheme.accent.gradient)
                .frame(width: 8, height: 118)
                .offset(y: -52)
                .shadow(color: AppTheme.accent.opacity(0.35), radius: 8)

            Capsule()
                .fill(Color.white.opacity(0.22))
                .frame(width: 6, height: 72)
                .offset(y: 42)
        }
    }
}

#Preview {
    CompassScreen()
        .environment(VCDataStore())
        .environment(LocationManager())
}
