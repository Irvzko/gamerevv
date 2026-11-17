//
//  UIComponents.swift
//  GameRev
//
//  Componentes visuales reutilizables estilo IMDb / IGDB con soporte para portadas reales
//  (AsyncImage) y respaldo estilizado sin conexión.
//  Los colores, radios y espaciados viven en Theme.swift.
//

import SwiftUI

// MARK: - Portada de Videojuego con Imagen Oficial + Fallback Estilizado
struct GameCoverBadge: View {
    let code: String
    var hexColor: String = "#1E3A5F"
    var imageURL: String = ""
    var width: CGFloat = 52
    var height: CGFloat = 72
    var cornerRadius: CGFloat = 12
    var fontSize: CGFloat = 17

    var body: some View {
        ZStack {
            fallbackArtwork
            if let url = URL(string: imageURL), !imageURL.isEmpty {
                AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.25))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .transition(.opacity)
                    default:
                        Color.clear
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 5, x: 0, y: 3)
        .accessibilityHidden(true)
    }

    private var fallbackArtwork: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: hexColor), Color.gameRevNavy],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(code)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.92))
        }
    }
}

extension GameCoverBadge {
    /// Portada de un juego usando su miniatura ligera.
    init(game: Game, width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 12, fontSize: CGFloat = 16) {
        self.init(
            code: game.code,
            hexColor: game.coverHex,
            imageURL: game.thumbnailImageURL,
            width: width,
            height: height,
            cornerRadius: cornerRadius,
            fontSize: fontSize
        )
    }
}

// MARK: - Imagen remota que rellena su contenedor sin desbordarlo
/// Un `scaledToFill` suelto puede ensanchar el contenedor más allá de la pantalla del iPhone.
/// Aquí la imagen va en un `overlay`, así que nunca altera el tamaño de quien la contiene.
struct RemoteFillImage: View {
    let urlString: String
    var fallbackHex: String = "#1E3A5F"

    var body: some View {
        LinearGradient(
            colors: [Color(hex: fallbackHex), Color.gameRevNavy],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            if let url = URL(string: urlString), !urlString.isEmpty {
                AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.3))) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                            .transition(.opacity)
                    }
                }
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

// MARK: - Avatar Circular
struct AvatarCircleBadge: View {
    let initials: String
    var size: CGFloat = 68
    var fontSize: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#312E81"), Color.gameRevNavy],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(initials)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(Color.gameRevGold)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Valoración y Metascore
struct StarRatingLabel: View {
    let text: String
    var size: CGFloat = 13
    /// `true` cuando se dibuja sobre una imagen o fondo oscuro.
    var onDarkBackground: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: size - 2))
                .foregroundColor(Color.gameRevGold)
            Text(text)
                .font(.system(size: size, weight: .bold))
                .foregroundColor(onDarkBackground ? .white : .primary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Valoración \(text) de 5")
    }
}

struct MetascoreBadge: View {
    let score: Int
    var compact: Bool = true

    var body: some View {
        Text(compact ? "\(score)" : "Metascore \(score)")
            .font(.system(size: 11, weight: .heavy))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(tint)
            )
            .accessibilityLabel("Metascore \(score)")
    }

    private var tint: Color {
        switch score {
        case 75...: return Color(hex: "#047857")
        case 50..<75: return Color(hex: "#B45309")
        default: return Color(hex: "#B91C1C")
        }
    }
}

// MARK: - Tarjeta de Fila de Videojuego Estilo IMDb
/// La valoración va bajo el título (y no en una columna aparte) para que el nombre
/// del juego tenga todo el ancho disponible en iPhone.
struct GameRowCardView: View {
    let game: Game
    var subtitleOverride: String? = nil

    var body: some View {
        HStack(alignment: .center, spacing: GRSpacing.md) {
            GameCoverBadge(game: game, width: 56, height: 80, cornerRadius: 10, fontSize: 15)

            VStack(alignment: .leading, spacing: 5) {
                Text(game.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(subtitleOverride ?? "\(game.releaseYearText) · \(game.developerName)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: GRSpacing.sm) {
                    StarRatingLabel(text: game.ratingText)
                    if game.hasMetascore {
                        MetascoreBadge(score: game.metascore)
                    }
                    Text(game.genres.prefix(2).joined(separator: " · "))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .grCard(padding: GRSpacing.md)
        .contentShape(Rectangle())
    }
}

// MARK: - Póster para Carruseles Horizontales
struct GamePosterCard: View {
    let game: Game
    var width: CGFloat = 124

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GameCoverBadge(
                game: game,
                width: width,
                height: width * 1.5,
                cornerRadius: 14,
                fontSize: 26
            )

            Text(game.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: width, height: 34, alignment: .topLeading)

            StarRatingLabel(text: game.ratingText, size: 12)
        }
        .frame(width: width, alignment: .leading)
    }
}

// MARK: - Encabezado de Sección
struct SectionHeaderView: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Spacer(minLength: GRSpacing.sm)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.gameRevLink)
                    .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Estados de Carga (esqueleto animado)
struct SkeletonBlock: View {
    var height: CGFloat
    var cornerRadius: CGFloat = 8
    @State private var isDimmed = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.primary.opacity(isDimmed ? 0.05 : 0.11))
            .frame(height: height)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                    isDimmed = true
                }
            }
    }
}

struct GameRowSkeletonView: View {
    var body: some View {
        HStack(spacing: GRSpacing.md) {
            SkeletonBlock(height: 80, cornerRadius: 10)
                .frame(width: 56)
            VStack(alignment: .leading, spacing: GRSpacing.sm) {
                SkeletonBlock(height: 15)
                SkeletonBlock(height: 12)
                    .frame(maxWidth: 160)
                SkeletonBlock(height: 12)
                    .frame(maxWidth: 110)
            }
        }
        .grCard(padding: GRSpacing.md)
        .accessibilityHidden(true)
    }
}

// MARK: - Aviso en Línea (no bloqueante)
struct InlineNoticeBanner: View {
    let iconName: String
    let text: String
    var tint: Color = .gameRevLink

    var body: some View {
        HStack(spacing: GRSpacing.sm) {
            Image(systemName: iconName)
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundColor(tint)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.12))
        )
    }
}

// MARK: - Tarjeta de Error Recuperable (Escena 12 · Manejo de errores y recuperación)
struct RecoverableErrorCardView: View {
    let errorType: RecoverableErrorType
    var customDetail: String? = nil
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: GRSpacing.md) {
            Text(errorType.rawValue)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tint.opacity(0.14))
                .foregroundColor(tint)
                .clipShape(Capsule())

            HStack(alignment: .top, spacing: GRSpacing.md) {
                Image(systemName: errorType == .emptyResults ? "magnifyingglass" : "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(tint)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(errorType.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(customDetail ?? errorType.message)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button(action: action) {
                Text(errorType.buttonTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.gameRevBlue)
                    )
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(GRSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.gameRevSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(tint.opacity(0.35), lineWidth: 1)
        )
    }

    private var tint: Color {
        errorType == .emptyResults ? Color.gameRevLink : Color.gameRevDanger
    }
}

// MARK: - Panel de Opciones de Prueba del Lab
struct LabInspectorSheetView: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Estado Actual del Sistema") {
                    statusRow(
                        label: "Sesión activa",
                        value: store.currentUser?.name ?? (store.isReaderMode ? "Modo Lector" : "Sin autenticar"),
                        tint: store.isAuthenticated ? .gameRevSuccess : .gameRevGoldText
                    )

                    statusRow(
                        label: "Catálogo",
                        value: store.catalogSource == .igdb ? "IGDB en vivo + local" : "Local (\(store.games.count) juegos)",
                        tint: store.catalogSource == .igdb ? .gameRevSuccess : .secondary
                    )

                    if let pending = store.pendingAction {
                        statusRow(label: "Acción pendiente", value: pending.descriptionText, tint: .gameRevLink)
                    }
                }

                Section("Pruebas de Estados y Resiliencia") {
                    Toggle("Simular fallo de red IGDB (CONNECTION_ERROR)", isOn: $store.simulateNetworkFailure)
                        .onChange(of: store.simulateNetworkFailure) { _ in
                            store.scheduleCatalogSearch()
                        }

                    Toggle("Simular Diario Vacío (EMPTY STATE)", isOn: $store.simulateEmptyDiary)

                    Button {
                        store.signOut()
                        dismiss()
                    } label: {
                        Label("Ir a Pantalla Bienvenido (Sin sesión)", systemImage: "rectangle.portrait.and.arrow.right")
                    }

                    Button {
                        store.enterAsReader()
                        store.selectedTab = .catalog
                        dismiss()
                    } label: {
                        Label("Activar Modo Lector (Probar acción protegida)", systemImage: "eye")
                    }

                    Button(role: .destructive) {
                        store.resetToDemoDefaults()
                        dismiss()
                    } label: {
                        Label("Restaurar datos originales", systemImage: "arrow.counterclockwise")
                    }
                }

                Section {
                    statusRow(
                        label: "Credenciales",
                        value: store.hasIGDBCredentials ? "Configuradas" : "Sin configurar",
                        tint: store.hasIGDBCredentials ? .gameRevSuccess : .secondary
                    )

                    TextField("Twitch Client-ID (opcional)", text: $store.igdbClientId)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif

                    SecureField("Access Token (opcional)", text: $store.igdbBearerToken)

                    Button {
                        Task {
                            await IGDBService.shared.resetSession()
                            store.scheduleCatalogSearch()
                        }
                    } label: {
                        Label("Probar conexión con IGDB", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .disabled(!store.hasIGDBCredentials)
                } header: {
                    Text("API de IGDB")
                } footer: {
                    Text("Lo habitual es definir IGDB_CLIENT_ID e IGDB_CLIENT_SECRET en Config/Secrets.xcconfig; la app pide y renueva el token sola. Estos campos solo sirven para pruebas rápidas y no se guardan.")
                }
            }
            .navigationTitle("Opciones de Prueba · Lab iOS")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    private func statusRow(label: String, value: String, tint: Color) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(tint)
                .multilineTextAlignment(.trailing)
        }
    }
}
