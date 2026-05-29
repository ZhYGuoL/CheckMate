import CoreLocation
import Foundation

@Observable
final class VCDataStore {
    private(set) var organizations: [VCOrganization] = []
    private(set) var loadError: String?

    init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(forResource: "vc_locations", withExtension: "json") else {
            loadError = "Could not find vc_locations.json in the app bundle."
            return
        }

        do {
            let data = try Data(contentsOf: url)
            organizations = try JSONDecoder().decode([VCOrganization].self, from: data)
                .sorted { $0.rank < $1.rank }
        } catch {
            loadError = error.localizedDescription
        }
    }

    func nearest(to userLocation: CLLocation) -> VCOrganization? {
        organizations.min { lhs, rhs in
            userLocation.distance(from: lhs.location) < userLocation.distance(from: rhs.location)
        }
    }
}
