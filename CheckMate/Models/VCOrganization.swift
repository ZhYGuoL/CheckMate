import CoreLocation
import MapKit

enum VCCategory: String, Codable, CaseIterable {
    case vc
    case accelerator
    case both

    var label: String {
        switch self {
        case .vc: "VC"
        case .accelerator: "Accelerator"
        case .both: "VC + Accelerator"
        }
    }

    var symbolName: String {
        switch self {
        case .vc: "chart.line.uptrend.xyaxis"
        case .accelerator: "bolt.fill"
        case .both: "sparkles"
        }
    }
}

struct VCOrganization: Identifiable, Codable, Hashable {
    let rank: Int
    let name: String
    let category: VCCategory
    let address: String
    let latitude: Double
    let longitude: Double

    var id: Int { rank }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    var initials: String {
        let words = name.split(separator: " ").filter { !$0.isEmpty }
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
