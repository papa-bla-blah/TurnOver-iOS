import SwiftUI

// MARK: - HIG-Compliant App Theme

public struct AppTheme {
    // MARK: - System Colors (Dark Mode Compatible)
    public static let primary = Color.accentColor
    public static let secondary = Color.secondary
    public static let accent = Color.orange
    public static let background = Color(uiColor: .systemBackground)
    public static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    public static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    public static let surface = Color(uiColor: .systemBackground)
    public static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    
    // Text Colors
    public static let textPrimary = Color(uiColor: .label)
    public static let textSecondary = Color(uiColor: .secondaryLabel)
    public static let textTertiary = Color(uiColor: .tertiaryLabel)
    public static let textPlaceholder = Color(uiColor: .placeholderText)
    
    // Semantic Colors
    public static let error = Color(uiColor: .systemRed)
    public static let success = Color(uiColor: .systemGreen)
    public static let warning = Color(uiColor: .systemOrange)
    public static let info = Color(uiColor: .systemBlue)
    
    // Separator
    public static let separator = Color(uiColor: .separator)
    
    // MARK: - Spacing (8pt Grid)
    public static let spacingXS: CGFloat = 4
    public static let spacingSM: CGFloat = 8
    public static let spacingMD: CGFloat = 16
    public static let spacingLG: CGFloat = 24
    public static let spacingXL: CGFloat = 32
    public static let spacingXXL: CGFloat = 48
    
    // MARK: - Corner Radius
    public static let radiusXS: CGFloat = 4
    public static let radiusSM: CGFloat = 8
    public static let radiusMD: CGFloat = 12
    public static let radiusLG: CGFloat = 16
    public static let radiusXL: CGFloat = 20
    
    // MARK: - Dynamic Type Fonts
    public static func dynamicFont(_ style: Font.TextStyle) -> Font {
        return Font.system(style)
    }
    
    // MARK: - Brand Colors (for accents only)
    public static let brandPrimary = Color(hex: "4A90A4")
    public static let brandSecondary = Color(hex: "5BA88F")
    public static let brandAccent = Color(hex: "E8B86D")
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - HIG Button Styles

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? AppTheme.primary : Color.gray)
            .cornerRadius(AppTheme.radiusMD)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isEnabled ? AppTheme.primary : .gray)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                    .stroke(isEnabled ? AppTheme.primary : Color.gray, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

public struct DestructiveButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.error)
            .cornerRadius(AppTheme.radiusMD)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Card Style

public struct CardStyle: ViewModifier {
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.radiusMD)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

extension View {
    public func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Dynamic Type Text Styles

public struct DynamicText: View {
    let text: String
    let style: Font.TextStyle
    let color: Color
    
    public init(_ text: String, style: Font.TextStyle = .body, color: Color = AppTheme.textPrimary) {
        self.text = text
        self.style = style
        self.color = color
    }
    
    public var body: some View {
        Text(text)
            .font(.system(style))
            .foregroundColor(color)
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }
}

// MARK: - Accessibility Helpers

extension View {
    public func accessibleTapTarget() -> some View {
        self.frame(minWidth: 44, minHeight: 44)
    }
}
