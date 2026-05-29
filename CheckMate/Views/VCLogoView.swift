import SwiftUI
import UIKit

enum LogoProvider {
    private static var cache: [Int: UIImage] = [:]

    static func image(for rank: Int) -> UIImage? {
        if let cached = cache[rank] {
            return cached
        }

        guard
            let url = Bundle.main.url(forResource: "\(rank)", withExtension: "png", subdirectory: "Logos"),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else {
            return nil
        }

        cache[rank] = image
        return image
    }
}

struct VCLogoView: View {
    let organization: VCOrganization
    var size: CGFloat = 28
    var isSelected: Bool = false
    var showsBorder: Bool = true

    var body: some View {
        Group {
            if let image = LogoProvider.image(for: organization.rank) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(organization.initials)
                    .font(.system(size: size * 0.34, weight: .bold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.accent.opacity(0.14))
            }
        }
        .frame(width: size, height: size)
        .background(Color.white)
        .clipShape(Circle())
        .overlay {
            if showsBorder {
                Circle()
                    .strokeBorder(
                        AppTheme.accent.opacity(isSelected ? 0.95 : 0.35),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            }
        }
        .shadow(color: AppTheme.accent.opacity(isSelected ? 0.35 : 0.18), radius: isSelected ? 10 : 5)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isSelected)
    }
}
