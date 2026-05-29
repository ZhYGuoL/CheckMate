import CoreLocation

@Observable
final class LocationManager: NSObject {
    private let manager = CLLocationManager()

    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var userLocation: CLLocation?
    var heading: CLHeading?
    var errorMessage: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1
        authorizationStatus = manager.authorizationStatus
    }

    func requestAccess() {
        refreshAuthorizationState()

        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    private func refreshAuthorizationState() {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            errorMessage = nil
            startUpdates()
        case .denied, .restricted:
            errorMessage = "Location access is off. Enable it in Settings to use the compass and nearby finder."
            stopUpdates()
        case .notDetermined:
            errorMessage = nil
        @unknown default:
            break
        }
    }

    func startUpdates() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        manager.requestLocation()
    }

    func stopUpdates() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        refreshAuthorizationState()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let nsError = error as NSError
        if nsError.code == CLError.locationUnknown.rawValue {
            return
        }
        if nsError.code == CLError.denied.rawValue {
            errorMessage = "Location access is off. Enable it in Settings to use the compass and nearby finder."
            return
        }
        errorMessage = error.localizedDescription
    }
}
