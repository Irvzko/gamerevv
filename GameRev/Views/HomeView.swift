//
//  HomeView.swift
//  GameRev
//
//  Implementa Escena 1 (Inicio con sesión restaurada) y Escena 2 (Menú principal
//  adaptativo para iPhone y Dashboard para MacBook / iPad).
//
//  Una sola composición que se ajusta al ancho disponible: en iPhone todo va en una
//  columna con carruseles horizontales; con más espacio, el destacado comparte fila
//  con la reseña más reciente y las listas pasan a varias columnas.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegular: Bool { horizontalSizeClass == .regular }
    private var horizontalPadding: CGFloat { isRegular ? 28 : 16 }
    private var posterWidth: CGFloat { isRegular ? 148 : 122 }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    Group {
                        greetingHeader

                        if store.isAuthenticated && store.sessionRestoredBanner {
                            // Banner de sesión restaurada de forma segura (Escena 1, pág. 4)
                            InlineNoticeBanner(
                                iconName: "checkmark.shield.fill",
                                text: "Sesión restaurada de forma segura",
                                tint: .gameRevSuccess
                            )
                        }

                        featuredSection
                    }
                    .padding(.horizontal, horizontalPadding)

                    shelf(title: "Tendencias en GameRev", games: store.trendingGames)
                    shelf(title: "Souls-like: prepárate para morir", games: store.games(inGenre: "Souls-like"))
                    shelf(title: "Mundos abiertos", games: store.games(inGenre: "Mundo abierto"))
                    shelf(title: "Indies imprescindibles", games: store.games(inGenre: "Indie"))

                    Group {
                        recentReviewsSection
                        recentlyViewedSection
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .padding(.vertical, isRegular ? 24 : 16)
                .frame(maxWidth: 1100, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .grScreenBackground()
            .navigationTitle("Inicio")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.showLabInspectorSheet = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .help("Abrir Inspector del Lab iOS (Escenas 01–13)")
                }
            }
            .navigationDestination(for: Game.self) { game in
                GameDetailView(game: game)
            }
            .navigationDestination(for: UserProfile.self) { profile in
                PublicProfileView(profile: profile)
            }
            .navigationDestination(for: Review.self) { review in
                ReviewDetailView(review: review)
            }
        }
    }

    // MARK: - Saludo
    private var greetingHeader: some View {
        HStack(alignment: .center, spacing: GRSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingLabel)
                    .grSectionLabel()

                Text("Hola, \(firstName)")
                    .font(.system(size: isRegular ? 32 : 28, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: GRSpacing.sm)

            if !store.isAuthenticated {
                Button {
                    store.signOut()
                } label: {
                    Text("Iniciar sesión")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.gameRevBlue.opacity(0.14)))
                        .foregroundColor(Color.gameRevLink)
                }
                .buttonStyle(.plain)
                .fixedSize()
            } else if isRegular {
                Button {
                    store.selectedTab = .catalog
                } label: {
                    Label("Buscar videojuegos...", systemImage: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(minWidth: 220, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.gameRevSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.gameRevStroke, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Juego Destacado (+ reseña más reciente si hay espacio)
    private var featuredSection: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 20) {
                featuredHero
                    .frame(minWidth: 420)
                latestReviewPanel
                    .frame(width: 280)
            }
            featuredHero
        }
    }

    private var featuredHero: some View {
        let game = store.featuredGame
        let height: CGFloat = isRegular ? 280 : 210

        return NavigationLink(value: game) {
            RemoteFillImage(urlString: game.lightBannerImageURL, fallbackHex: game.coverHex)
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.05), Color.gameRevNavy.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("JUEGO DESTACADO")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(Color.gameRevGold)

                        Text(game.title)
                            .font(.system(size: isRegular ? 26 : 21, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: GRSpacing.sm) {
                            StarRatingLabel(text: game.ratingText, onDarkBackground: true)
                            Text(game.genres.prefix(3).joined(separator: " · "))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.78))
                                .lineLimit(1)
                        }
                    }
                    .padding(GRSpacing.lg)
                }
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .clipShape(RoundedRectangle(cornerRadius: GRRadius.hero, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Juego destacado: \(game.title)")
    }

    private var latestReviewPanel: some View {
        VStack(alignment: .leading, spacing: GRSpacing.md) {
            Text("Reseñas\nrecientes")
                .font(.system(size: 22, weight: .bold, design: .rounded))

            if let topReview = store.recentReviews(limit: 1).first {
                Text("\"\(topReview.text)\"")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(5)

                Text("@\(topReview.authorUsername)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.gameRevLink)
            }

            Spacer(minLength: 0)

            Button {
                store.selectedTab = .reviews
            } label: {
                Text("Explorar conversación →")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.gameRevLink)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, minHeight: 244, alignment: .topLeading)
        .grCard(padding: 18, radius: GRRadius.hero)
    }

    // MARK: - Carrusel horizontal de pósters
    @ViewBuilder
    private func shelf(title: String, games: [Game]) -> some View {
        if !games.isEmpty {
            VStack(alignment: .leading, spacing: GRSpacing.md) {
                SectionHeaderView(title: title, actionTitle: "Ver catálogo") {
                    store.selectedTab = .catalog
                }
                .padding(.horizontal, horizontalPadding)

                ScrollView(.horizontal, showsIndicators: false) {
                    // LazyHStack: solo se crean (y descargan) los pósters visibles.
                    LazyHStack(alignment: .top, spacing: 14) {
                        ForEach(games) { game in
                            NavigationLink(value: game) {
                                GamePosterCard(game: game, width: posterWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                .frame(height: posterWidth * 1.5 + 72)
            }
        }
    }

    // MARK: - Reseñas recientes
    private var recentReviewsSection: some View {
        VStack(alignment: .leading, spacing: GRSpacing.md) {
            SectionHeaderView(title: "Reseñas recientes", actionTitle: "Ver todas") {
                store.selectedTab = .reviews
            }

            LazyVGrid(columns: adaptiveColumns, alignment: .leading, spacing: GRSpacing.md) {
                ForEach(store.recentReviews(limit: isRegular ? 4 : 3)) { review in
                    NavigationLink(value: review) {
                        ReviewCardView(review: review, textLineLimit: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Últimos consultados
    private var recentlyViewedSection: some View {
        VStack(alignment: .leading, spacing: GRSpacing.md) {
            SectionHeaderView(title: "Últimos consultados")

            LazyVGrid(columns: adaptiveColumns, alignment: .leading, spacing: GRSpacing.md) {
                ForEach(store.recentGames.prefix(isRegular ? 4 : 3)) { game in
                    NavigationLink(value: game) {
                        GameRowCardView(game: game)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    /// Una columna en iPhone; dos o más cuando el ancho lo permite.
    private var adaptiveColumns: [GridItem] {
        if isRegular {
            return [GridItem(.adaptive(minimum: 340), spacing: GRSpacing.md, alignment: .top)]
        }
        return [GridItem(.flexible(), alignment: .top)]
    }

    // MARK: - Textos
    private var greetingLabel: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: return "BUENOS DÍAS"
        case 12..<20: return "BUENAS TARDES"
        default: return "BUENAS NOCHES"
        }
    }

    private var firstName: String {
        if let user = store.currentUser {
            return String(user.name.split(separator: " ").first ?? Substring(user.name))
        }
        return "Lector"
    }
}
