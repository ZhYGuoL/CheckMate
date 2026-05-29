import SwiftUI

enum AppTheme {
    static let backgroundTop = Color(red: 0.04, green: 0.07, blue: 0.08)
    static let backgroundBottom = Color(red: 0.07, green: 0.12, blue: 0.11)
    static let accent = Color(red: 0.28, green: 0.84, blue: 0.62)
    static let accentDeep = Color(red: 0.16, green: 0.62, blue: 0.48)
    static let accentSecondary = Color(red: 0.34, green: 0.72, blue: 0.66)
    static let card = Color.white.opacity(0.08)
    static let subtleText = Color.white.opacity(0.62)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func categoryColor(_ category: VCCategory) -> Color {
        switch category {
        case .vc: accent
        case .accelerator: accentSecondary
        case .both: Color(red: 0.52, green: 0.88, blue: 0.72)
        }
    }
}

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(AppTheme.accent.opacity(0.10)).interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(AppTheme.accent.opacity(0.16), lineWidth: 1)
                }
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}
