//
//  ProfileViews.swift
//  GameRev
//
//  Implementa Diagramas 06 y 07, Escena 9 (Consultar perfil de creador),
//  Escena 10 (Mi perfil y edición condicional Jugador/Creador con editor de portafolio) y
//  Escena 11 (Control de permisos y comprobación de propiedad).
//

import SwiftUI

struct ProfileTabRootView: View {
    @EnvironmentObject var store: AppStateStore
    @State private var selectedSection: ProfileSection = .myProfile
    @State private var directorySearch: String = ""
    @State private var directoryTypeFilter: String = "Todos" // "Todos" | "Creadores" | "Jugadores"

    enum ProfileSection: String, CaseIterable {
        case myProfile = "Mi perfil"
        case publicDirectory = "Directorio público"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Sección de perfiles", selection: $selectedSection) {
                    ForEach(ProfileSection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                if selectedSection == .myProfile {
                    if let user = store.currentUser {
                        MyProfileDetailContent(user: user)
                    } else {
                        unauthenticatedProfileGate
                    }
                } else {
                    publicProfilesDirectoryContent
                }
            }
            .grScreenBackground()
            .navigationTitle(selectedSection == .myProfile ? "Mi perfil" : "Perfiles y Creadores")
            .toolbar {
                if store.isAuthenticated && selectedSection == .myProfile {
                    ToolbarItem(placement: .primaryAction) {
                        Button(role: .destructive) {
                            store.signOut()
                        } label: {
                            Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .navigationDestination(for: UserProfile.self) { profile in
                PublicProfileView(profile: profile)
            }
            .navigationDestination(for: Game.self) { game in
                GameDetailView(game: game)
            }
        }
    }

    private var unauthenticatedProfileGate: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 40)

                AvatarCircleBadge(initials: "GR", size: 78, fontSize: 24)

                Text("\"Mi perfil\" requiere iniciar sesión")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Como lector puedes explorar todos los perfiles públicos, diarios de la comunidad y portafolios de estudios y artistas. Inicia sesión para gestionar tu propio perfil.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    store.requireAuthenticationOrPerform(.openMyProfile)
                } label: {
                    Text("Iniciar sesión o crear cuenta")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.gameRevBlue)
                        )
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)

                Button {
                    selectedSection = .publicDirectory
                } label: {
                    Text("Explorar buscador de perfiles públicos y creadores →")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.gameRevLink)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
    }

    private var publicProfilesDirectoryContent: some View {
        let filteredProfiles = store.profiles.filter { profile in
            let matchesType: Bool
            if directoryTypeFilter == "Creadores" {
                matchesType = profile.isCreator
            } else if directoryTypeFilter == "Jugadores" {
                matchesType = !profile.isCreator
            } else {
                matchesType = true
            }

            let q = directorySearch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !q.isEmpty else { return matchesType }
            let matchesSearch =
                profile.name.lowercased().contains(q) ||
                profile.username.lowercased().contains(q) ||
                profile.creatorRole.lowercased().contains(q) ||
                profile.studioOrProject.lowercased().contains(q) ||
                profile.bio.lowercased().contains(q)
            return matchesType && matchesSearch
        }

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Buscar creador, estudio o jugador (ej. Team Cherry, Marina)...", text: $directorySearch)
                        .textFieldStyle(.plain)
                    if !directorySearch.isEmpty {
                        Button {
                            directorySearch = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                )

                HStack(spacing: 8) {
                    ForEach(["Todos", "Creadores", "Jugadores"], id: \.self) { typeOpt in
                        Button {
                            directoryTypeFilter = typeOpt
                        } label: {
                            Text(typeOpt)
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(directoryTypeFilter == typeOpt ? Color.gameRevBlue : Color.primary.opacity(0.07))
                                )
                                .foregroundColor(directoryTypeFilter == typeOpt ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text("RESULTADOS (\(filteredProfiles.count))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)

                ForEach(filteredProfiles) { profile in
                    NavigationLink(value: profile) {
                        HStack(spacing: 14) {
                            AvatarCircleBadge(initials: profile.initials, size: 54, fontSize: 17)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(profile.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)

                                    if profile.id == store.currentUser?.id {
                                        Text("Tú")
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gameRevSuccess.opacity(0.15))
                                            .foregroundColor(Color.gameRevSuccess)
                                            .clipShape(Capsule())
                                    }
                                }

                                Text(profile.roleBadgeText)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color.gameRevLink)

                                Text(profile.bio)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.gameRevSurface)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Vista "Mi perfil" del Propietario
struct MyProfileDetailContent: View {
    @EnvironmentObject var store: AppStateStore
    let user: UserProfile

    var body: some View {
        let userEntries = store.userDiaryEntries(for: user.id)
        let userReviews = store.reviews.filter { $0.authorId == user.id }

        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 12) {
                    AvatarCircleBadge(initials: user.initials, size: 84, fontSize: 26)

                    Text(user.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))

                    Text("@\(user.username) · \(user.roleBadgeText)")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.gameRevBlue.opacity(0.14)))
                        .foregroundColor(Color.gameRevBlue)

                    Text(user.bio)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 10)

                if store.canEditProfile(user) {
                    Button {
                        store.showEditMyProfileSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                            Text("Editar perfil y portafolio")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.gameRevBlue)
                        )
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 48) {
                    Button {
                        store.selectedTab = .diary
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(userEntries.count)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            Text("En mi diario")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.selectedTab = .reviews
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(userReviews.count)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Mis reseñas")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.gameRevSurface)
                )

                if user.isCreator {
                    creatorPortfolioSection(for: user)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("TALENTO Y CREADORES EN GAMEREV")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    ForEach(store.profiles.filter { $0.id != user.id }.prefix(4)) { creator in
                        NavigationLink(value: creator) {
                            HStack(spacing: 12) {
                                AvatarCircleBadge(initials: creator.initials, size: 42, fontSize: 14)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(creator.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text(creator.roleBadgeText)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color.gameRevLink)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.gameRevSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
    }

    @ViewBuilder
    private func creatorPortfolioSection(for profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if !profile.studioOrProject.isEmpty {
                HStack {
                    Text("Estudio / Proyecto:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(profile.studioOrProject)
                        .font(.caption.weight(.bold))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Trayectoria")
                    .font(.system(size: 15, weight: .bold))
                Text(profile.trajectory)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            if !profile.portfolio.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Portafolio de trabajos (\(profile.portfolio.count))")
                        .font(.system(size: 15, weight: .bold))

                    ForEach(profile.portfolio) { work in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(work.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(work.year)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color.gameRevGold)
                            }
                            Text(work.role)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.gameRevLink)
                            if !work.summary.isEmpty {
                                Text(work.summary)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.gameRevNavy)
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.gameRevSurface)
        )
    }
}

// MARK: - Perfil Público (Creadores y Jugadores) + Control de Permisos
struct PublicProfileView: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.openURL) private var openURL

    let profile: UserProfile

    @State private var selectedWorkDetail: PortfolioWork? = nil
    @State private var showUnauthorizedDemoError: Bool = false

    var isOwner: Bool {
        store.canEditProfile(profile)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 12) {
                    AvatarCircleBadge(initials: profile.initials, size: 84, fontSize: 26)

                    Text(profile.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))

                    Text("@\(profile.username) · \(profile.roleBadgeText)")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.gameRevBlue.opacity(0.14)))
                        .foregroundColor(Color.gameRevBlue)

                    Text(profile.bio)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 8)

                if profile.isCreator {
                    VStack(alignment: .leading, spacing: 18) {
                        if !profile.trajectory.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Trayectoria")
                                    .font(.system(size: 16, weight: .bold))
                                Text(profile.trajectory)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }

                        if !profile.portfolio.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Portafolio de trabajos realizados (\(profile.portfolio.count))")
                                    .font(.system(size: 16, weight: .bold))

                                ForEach(profile.portfolio) { work in
                                    Button {
                                        selectedWorkDetail = work
                                    } label: {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Text(work.title)
                                                    .font(.system(size: 15, weight: .bold))
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(work.year)
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(Color.gameRevGold)
                                            }
                                            Text(work.role)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color.gameRevLink)
                                            Text(work.summary)
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.78))
                                                .multilineTextAlignment(.leading)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(Color.gameRevNavy)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if !profile.contactURL.isEmpty {
                            Button {
                                let raw = profile.contactURL.hasPrefix("http") ? profile.contactURL : "https://\(profile.contactURL)"
                                if let url = URL(string: raw) {
                                    openURL(url)
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Visitar sitio oficial / contacto")
                                    Image(systemName: "arrow.up.right.square")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.gameRevBlue.opacity(0.12))
                                )
                                .foregroundColor(Color.gameRevBlue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Control de Permisos (Diagramas 06 y 07)
                if isOwner {
                    Button {
                        store.showEditMyProfileSheet = true
                    } label: {
                        Label("Editar mi perfil y portafolio", systemImage: "pencil")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.gameRevBlue)
                            )
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation {
                                showUnauthorizedDemoError = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.shield")
                                Text("Perfil ajeno en modo lectura (Probar validación de propiedad)")
                                Spacer()
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                                    .foregroundColor(.secondary.opacity(0.4))
                            )
                        }
                        .buttonStyle(.plain)

                        if showUnauthorizedDemoError {
                            RecoverableErrorCardView(errorType: .unauthorized) {
                                withAnimation {
                                    showUnauthorizedDemoError = false
                                }
                            }
                        }
                    }
                }

                publicActivitySection
            }
            .padding(20)
        }
        .grScreenBackground()
        .navigationTitle(profile.name)
        .sheet(item: $selectedWorkDetail) { work in
            NavigationStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text(work.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Rol: \(work.role) · Año: \(work.year)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.gameRevLink)
                    Text(work.summary)
                        .font(.body)
                        .foregroundColor(.secondary)
                    if let relatedId = work.relatedGameId,
                       let relatedGame = store.game(for: relatedId) {
                        Divider()
                        Text("Videojuego asociado en el catálogo:")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.secondary)
                        GameRowCardView(game: relatedGame)
                    }
                    Spacer()
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .grScreenBackground()
                .navigationTitle("Detalle de obra")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Cerrar") { selectedWorkDetail = nil }
                    }
                }
            }
        }
    }

    private var publicActivitySection: some View {
        let publicEntries = store.userDiaryEntries(for: profile.id)
        let publicReviews = store.reviews.filter { $0.authorId == profile.id }

        return VStack(alignment: .leading, spacing: 14) {
            Text("DIARIO PÚBLICO DE \(profile.name.uppercased()) (\(publicEntries.count))")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)

            if publicEntries.isEmpty {
                Text("Este perfil aún no tiene entradas públicas en su diario.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(publicEntries) { entry in
                    if let game = store.game(for: entry.gameId) {
                        NavigationLink(value: game) {
                            GameRowCardView(
                                game: game,
                                subtitleOverride: "\(entry.status.rawValue) · \(entry.personalNote)"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !publicReviews.isEmpty {
                Text("RESEÑAS PÚBLICAS (\(publicReviews.count))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.top, 6)

                ForEach(publicReviews) { review in
                    let gameTitle = store.game(for: review.gameId)?.title ?? "Videojuego"
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(gameTitle)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.gameRevLink)
                            Spacer()
                            Text(String(format: "★ %.1f", review.rating))
                                .font(.caption.weight(.bold))
                                .foregroundColor(Color.gameRevGold)
                        }
                        Text("\"\(review.text)\"")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.gameRevSurface)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Formulario "Editar perfil" con Editor Completo de Trabajos del Portafolio (Diagrama 07)
struct EditProfileSheet: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var profileType: ProfileType = .player
    @State private var studioOrProject: String = ""
    @State private var creatorRole: String = ""
    @State private var trajectory: String = ""
    @State private var contactURL: String = ""
    @State private var portfolio: [PortfolioWork] = []

    @State private var editingWorkId: UUID? = nil
    @State private var workTitle: String = ""
    @State private var workRole: String = ""
    @State private var workYear: String = "2026"
    @State private var workSummary: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let errorMessage {
                        RecoverableErrorCardView(errorType: .invalidForm, customDetail: errorMessage) {
                            self.errorMessage = nil
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nombre")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        TextField("Mauro Barcenas", text: $name)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Descripción / Biografía")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        TextField("Cazador de indies...", text: $bio, axis: .vertical)
                            .lineLimit(2...4)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("TIPO DE PERFIL")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)

                        HStack(spacing: 10) {
                            ForEach(ProfileType.allCases) { type in
                                Button {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        profileType = type
                                    }
                                } label: {
                                    Text(type.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 11)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(profileType == type ? Color.gameRevBlue.opacity(0.16) : Color.primary.opacity(0.05))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .strokeBorder(profileType == type ? Color.gameRevBlue : Color.clear, lineWidth: 1.5)
                                                )
                                        )
                                        .foregroundColor(profileType == type ? Color.gameRevBlue : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if profileType == .creator {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("DATOS DE CREADOR Y PORTAFOLIO")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.gameRevSuccess.opacity(0.15))
                                .foregroundColor(Color.gameRevSuccess)
                                .clipShape(Capsule())

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Estudio o proyecto")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                                TextField("Moonlit Studio", text: $studioOrProject)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Rol o especialidad")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                                TextField("Artista conceptual / Desarrollador", text: $creatorRole)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Trayectoria y descripción de trabajo")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                                TextField("Entornos, personajes y dirección visual...", text: $trajectory, axis: .vertical)
                                    .lineLimit(2...4)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Enlace público de contacto (opcional)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                                TextField("https://portfolio.example", text: $contactURL)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                            }

                            Divider()

                            // Lista y Editor Completo de Trabajos del Portafolio
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Trabajos realizados en tu portafolio (\(portfolio.count))")
                                    .font(.subheadline.weight(.bold))

                                ForEach(portfolio) { work in
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("\(work.title) (\(work.year))")
                                                .font(.system(size: 14, weight: .bold))
                                            Text(work.role)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color.gameRevLink)
                                            if !work.summary.isEmpty {
                                                Text(work.summary)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Button {
                                            loadWorkIntoForm(work)
                                        } label: {
                                            Image(systemName: "pencil")
                                                .padding(6)
                                        }
                                        .buttonStyle(.plain)

                                        Button(role: .destructive) {
                                            portfolio.removeAll(where: { $0.id == work.id })
                                            if editingWorkId == work.id {
                                                clearWorkForm()
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(Color.gameRevDanger)
                                                .padding(6)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                                }

                                // Formulario para añadir o editar un trabajo del portafolio
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(editingWorkId == nil ? "+ Añadir nuevo trabajo al portafolio" : "✎ Editando trabajo seleccionado")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(Color.gameRevLink)

                                    HStack(spacing: 8) {
                                        TextField("Título de la obra", text: $workTitle)
                                            .textFieldStyle(.roundedBorder)
                                        TextField("Año", text: $workYear)
                                            .frame(width: 72)
                                            .textFieldStyle(.roundedBorder)
                                    }

                                    TextField("Tu rol en este proyecto (ej. Diseño de niveles, Ilustración)", text: $workRole)
                                        .textFieldStyle(.roundedBorder)

                                    TextField("Descripción breve del trabajo realizado", text: $workSummary)
                                        .textFieldStyle(.roundedBorder)

                                    HStack {
                                        Button(editingWorkId == nil ? "Añadir trabajo" : "Actualizar trabajo") {
                                            saveOrUpdatePortfolioWork()
                                        }
                                        .buttonStyle(.borderedProminent)

                                        if editingWorkId != nil {
                                            Button("Cancelar edición") {
                                                clearWorkForm()
                                            }
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.primary.opacity(0.12)))
                            }
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.primary.opacity(0.03)))
                    }

                    Button {
                        saveChanges()
                    } label: {
                        Text("Guardar perfil y portafolio")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.gameRevBlue))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
            }
            .grScreenBackground()
            .navigationTitle("Editar perfil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { saveChanges() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let user = store.currentUser {
                    name = user.name
                    bio = user.bio
                    profileType = user.profileType
                    studioOrProject = user.studioOrProject.isEmpty ? "Moonlit Studio" : user.studioOrProject
                    creatorRole = user.creatorRole.isEmpty ? "Artista conceptual" : user.creatorRole
                    trajectory = user.trajectory.isEmpty ? "Entornos y personajes" : user.trajectory
                    contactURL = user.contactURL.isEmpty ? "https://portfolio.example" : user.contactURL
                    portfolio = user.portfolio
                }
            }
        }
    }

    private func loadWorkIntoForm(_ work: PortfolioWork) {
        editingWorkId = work.id
        workTitle = work.title
        workRole = work.role
        workYear = work.year
        workSummary = work.summary
    }

    private func clearWorkForm() {
        editingWorkId = nil
        workTitle = ""
        workRole = ""
        workYear = "2026"
        workSummary = ""
    }

    private func saveOrUpdatePortfolioWork() {
        let cleanTitle = workTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }
        let cleanRole = workRole.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanYear = workYear.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSummary = workSummary.trimmingCharacters(in: .whitespacesAndNewlines)

        if let editingWorkId,
           let idx = portfolio.firstIndex(where: { $0.id == editingWorkId }) {
            portfolio[idx].title = cleanTitle
            portfolio[idx].role = cleanRole.isEmpty ? creatorRole : cleanRole
            portfolio[idx].year = cleanYear.isEmpty ? "2026" : cleanYear
            portfolio[idx].summary = cleanSummary.isEmpty ? "Trabajo registrado en el portafolio." : cleanSummary
        } else {
            portfolio.append(
                PortfolioWork(
                    title: cleanTitle,
                    role: cleanRole.isEmpty ? creatorRole : cleanRole,
                    summary: cleanSummary.isEmpty ? "Trabajo registrado en el portafolio." : cleanSummary,
                    year: cleanYear.isEmpty ? "2026" : cleanYear
                )
            )
        }
        clearWorkForm()
    }

    private func saveChanges() {
        guard let user = store.currentUser else { return }
        if let error = store.updateOwnProfile(
            targetProfile: user,
            name: name,
            bio: bio,
            profileType: profileType,
            studioOrProject: studioOrProject,
            creatorRole: creatorRole,
            trajectory: trajectory,
            contactURL: contactURL,
            portfolio: portfolio
        ) {
            errorMessage = error
        } else {
            dismiss()
        }
    }
}
