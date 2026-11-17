//
//  Theme.swift
//  GameRev
//
//  Sistema de diseño de GameRev: paleta adaptativa (claro / oscuro), espaciados,
//  radios y modificadores reutilizables. Todas las vistas deben consumir estos
//  tokens en lugar de colores del sistema (.blue, .green, .orange) o valores sueltos.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Colores base
extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (30, 58, 95)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }

    /// Color que cambia automáticamente entre modo claro y oscuro.
    init(light: String, dark: String) {
        #if canImport(UIKit)
        self.init(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
        #elseif canImport(AppKit)
        self.init(NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(Color(hex: dark))
                : NSColor(Color(hex: light))
        })
        #else
        self.init(hex: light)
        #endif
    }

    // Marca (fijos: se usan sobre fondos oscuros o como relleno con texto blanco)
    static let gameRevNavy = Color(hex: "#0B1020")
    static let gameRevCardDark = Color(hex: "#161C2E")
    static let gameRevGold = Color(hex: "#F5B93A")

    /// Relleno principal de botones (siempre con texto blanco encima).
    static let gameRevBlue = Color(light: "#4F46E5", dark: "#6366F1")

    // Superficies
    /// Fondo general de cada pantalla.
    static let gameRevBackground = Color(light: "#F5F6FA", dark: "#0B1020")
    /// Fondo de tarjetas y paneles.
    static let gameRevSurface = Color(light: "#FFFFFF", dark: "#161C2E")
    /// Borde sutil de tarjetas.
    static let gameRevStroke = Color(light: "#E3E6EF", dark: "#252C42")

    // Texto y estados semánticos (contraste AA en ambos modos)
    /// Enlaces, acentos de texto y etiquetas informativas.
    static let gameRevLink = Color(light: "#4338CA", dark: "#A5B4FC")
    /// Texto de valoraciones (el dorado puro no se lee sobre blanco).
    static let gameRevGoldText = Color(light: "#B45309", dark: "#FBBF24")
    static let gameRevSuccess = Color(light: "#047857", dark: "#34D399")
    static let gameRevDanger = Color(light: "#DC2626", dark: "#F87171")
}

// MARK: - Espaciados y radios
enum GRSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

enum GRRadius {
    static let chip: CGFloat = 10
    static let card: CGFloat = 16
    static let hero: CGFloat = 22
}

// MARK: - Modificadores
private struct GRCardModifier: ViewModifier {
    var padding: CGFloat
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.gameRevSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.gameRevStroke, lineWidth: 1)
            )
    }
}

private struct GRAdaptiveContentModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var maxWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalSizeClass == .regular ? 28 : 16)
            .padding(.vertical, horizontalSizeClass == .regular ? 24 : 16)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    /// Tarjeta estándar: superficie, borde sutil y radio continuo.
    func grCard(padding: CGFloat = GRSpacing.lg, radius: CGFloat = GRRadius.card) -> some View {
        modifier(GRCardModifier(padding: padding, radius: radius))
    }

    /// Fondo de pantalla de la app (respeta modo claro / oscuro).
    func grScreenBackground() -> some View {
        background(Color.gameRevBackground.ignoresSafeArea())
    }

    /// Márgenes que se ajustan al ancho: 16 pt en iPhone, 28 pt en iPad / Mac,
    /// con un ancho máximo de lectura para que el contenido no se estire.
    func grAdaptiveContent(maxWidth: CGFloat = 1100) -> some View {
        modifier(GRAdaptiveContentModifier(maxWidth: maxWidth))
    }

    /// Encabezado de sección en versalitas.
    func grSectionLabel() -> some View {
        font(.system(size: 12, weight: .bold))
            .tracking(0.6)
            .foregroundColor(.secondary)
    }
}

// MARK: - Estilos de botón
struct GRPrimaryButtonStyle: ButtonStyle {
    var fill: Color = .gameRevBlue
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(fill)
            )
            .foregroundColor(foreground)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
