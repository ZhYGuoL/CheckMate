import CoreLocation

enum GeoHelpers {
    static func distance(from origin: CLLocation, to destination: CLLocation) -> CLLocationDistance {
        origin.distance(from: destination)
    }

    static func bearing(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = origin.latitude * .pi / 180
        let lat2 = destination.latitude * .pi / 180
        let deltaLon = (destination.longitude - origin.longitude) * .pi / 180

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let radians = atan2(y, x)
        let degrees = radians * 180 / .pi
        return degrees >= 0 ? degrees : degrees + 360
    }

    static func formattedDistance(_ meters: CLLocationDistance) -> String {
        let miles = meters / 1609.344
        if miles < 0.1 {
            return String(format: "%.0f ft", meters * 3.28084)
        }
        return String(format: "%.1f mi", miles)
    }

    static func formattedBearing(_ degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((degrees + 22.5).truncatingRemainder(dividingBy: 360) / 45)
        return directions[index]
    }
}
