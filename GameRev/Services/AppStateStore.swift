//
//  AppStateStore.swift
//  GameRev
//
//  Estado centralizado y persistencia de la aplicación (iOS + macOS).
//  Implementa todos los flujos de decisión de los diagramas 01 a 07 y las 13 escenas.
//

import Foundation
import SwiftUI

struct PersistedAppSnapshot: Codable {
    var profiles: [UserProfile]
    var games: [Game]
    var categories: [GameCategory]
    var diaryEntries: [DiaryEntry]
    var reviews: [Review]
    var comments: [ReviewComment]
    var activeUserId: UUID?
    var isReaderMode: Bool
    var recentGameIds: [UUID]
}

@MainActor
final class AppStateStore: ObservableObject {
    // MARK: - Estado de Arranque y Sesión (Escena 1 y Diagrama 02)
    @Published var isCheckingSession: Bool = true
    @Published var currentUser: UserProfile? = nil
    @Published var isReaderMode: Bool = false
    @Published var sessionRestoredBanner: Bool = false

    // MARK: - Navegación Principal (Escena 2 y Diagrama 01)
    @Published var selectedTab: MainTab = .home
    @Published var selectedGameForDetail: Game? = nil
    @Published var selectedCreatorProfile: UserProfile? = nil
    @Published var filterReviewsByGame: Game? = nil

    // MARK: - Acción Protegida y Recuperación (Escena 5 y Diagrama 02)
    @Published var pendingAction: PendingAction? = nil
    @Published var showProtectedAuthSheet: Bool = false
    @Published var activeDiaryEditorGame: Game? = nil
    @Published var activeNewReviewGame: Game? = nil
    @Published var showNewReviewSheet: Bool = false
    @Published var activeCommentReview: Review? = nil
    @Published var showEditMyProfileSheet: Bool = false

    // MARK: - Datos Persistidos
    @Published var profiles: [UserProfile] = SeedData.initialProfiles
    @Published var games: [Game] = SeedData.initialGames
    @Published var categories: [GameCategory] = SeedData.initialCategories
    @Published var diaryEntries: [DiaryEntry] = SeedData.initialDiaryEntries
    @Published var reviews: [Review] = SeedData.initialReviews
    @Published var comments: [ReviewComment] = SeedData.initialComments
    @Published var recentGameIds: [UUID] = [
        SeedData.hades2Id,
        SeedData.celesteId,
        SeedData.seaOfStarsId
    ]

    // MARK: - Estado de Catálogo e IGDB (Escena 3 y Escena 12)
    @Published var searchQuery: String = ""
    @Published var selectedGenreFilter: String = "Todos"
    @Published var selectedPlatformFilter: String = "Todas"
    @Published var selectedYearFilter: Int? = nil
    @Published var catalogResults: [Game] = SeedData.initialGames
    @Published var isSearchingCatalog: Bool = false
    @Published var catalogConnectionError: Bool = false
    /// De dónde salieron los resultados actuales (catálogo local o IGDB en vivo).
    @Published var catalogSource: CatalogDataSource = .local
    /// Aviso no bloqueante: IGDB falló pero se muestra el catálogo local.
    @Published var catalogRemoteNotice: String? = nil
    /// Cuántos resultados se dibujan. Crece por tramos del 30 % para cuidar la memoria.
    @Published var catalogVisibleCount: Int = 0
    @Published var simulateNetworkFailure: Bool = false
    @Published var igdbClientId: String = ""
    @Published var igdbBearerToken: String = ""

    // MARK: - Filtros del Diario (Escena 6)
    @Published var diaryStatusFilter: DiaryStatus? = nil
    @Published var diaryCategoryFilterId: UUID? = nil
    @Published var simulateEmptyDiary: Bool = false

    // MARK: - Inspector del Laboratorio (Escena 12 y 13)
    @Published var showLabInspectorSheet: Bool = false
    @Published var unauthorizedBannerVisible: Bool = false

    // v3: el catálogo semilla creció (Dark Souls, Skyrim, Elden Ring…).
    private let storageKey = "com.equipo6.gamerev.persistedSnapshot.v3"

    /// Fracción del catálogo que se muestra por tramo en listas y carruseles.
    static let catalogPageFraction: Double = 0.30
    static let reviewCharacterLimit: Int = 280

    private var catalogSearchTask: Task<Void, Never>?

    init() {
        loadPersistedState()
    }

    // MARK: - Inicialización y Comprobación de Sesión (Escena 1)
    func performInitialSessionCheck() async {
        isCheckingSession = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        isCheckingSession = false
        if currentUser != nil {
            sessionRestoredBanner = true
        }
        scheduleCatalogSearch()
    }

    // MARK: - Persistencia Local JSON
    func saveState() {
        let snapshot = PersistedAppSnapshot(
            profiles: profiles,
            games: games,
            categories: categories,
            diaryEntries: diaryEntries,
            reviews: reviews,
            comments: comments,
            activeUserId: currentUser?.id,
            isReaderMode: isReaderMode,
            recentGameIds: recentGameIds
        )
        if let encoded = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    func loadPersistedState() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(PersistedAppSnapshot.self, from: data) else {
            currentUser = profiles.first(where: { $0.id == SeedData.mauroId })
            isReaderMode = false
            catalogResults = games
            catalogVisibleCount = catalogPageSize
            return
        }

        self.profiles = snapshot.profiles
        // Si una versión nueva de la app trae más juegos semilla, se añaden a lo guardado.
        let savedIds = Set(snapshot.games.map(\.id))
        self.games = snapshot.games + SeedData.initialGames.filter { !savedIds.contains($0.id) }
        self.categories = snapshot.categories
        self.diaryEntries = snapshot.diaryEntries
        self.reviews = snapshot.reviews
        self.comments = snapshot.comments
        self.recentGameIds = snapshot.recentGameIds

        if let activeId = snapshot.activeUserId,
           let foundUser = snapshot.profiles.first(where: { $0.id == activeId }) {
            self.currentUser = foundUser
            self.isReaderMode = false
        } else {
            self.currentUser = nil
            self.isReaderMode = snapshot.isReaderMode
        }
        self.catalogResults = self.games
        self.catalogVisibleCount = catalogPageSize
    }

    func resetToDemoDefaults() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        profiles = SeedData.initialProfiles
        games = SeedData.initialGames
        categories = SeedData.initialCategories
        diaryEntries = SeedData.initialDiaryEntries
        reviews = SeedData.initialReviews
        comments = SeedData.initialComments
        recentGameIds = [SeedData.hades2Id, SeedData.celesteId, SeedData.seaOfStarsId]
        currentUser = profiles.first(where: { $0.id == SeedData.mauroId })
        isReaderMode = false
        pendingAction = nil
        simulateNetworkFailure = false
        simulateEmptyDiary = false
        catalogConnectionError = false
        catalogRemoteNotice = nil
        catalogSource = .local
        catalogResults = games
        catalogVisibleCount = catalogPageSize
        diaryStatusFilter = nil
        diaryCategoryFilterId = nil
        saveState()
    }

    // MARK: - Autenticación, Registro y Modo Lector (Diagrama 02 y Escena 5)
    var isAuthenticated: Bool {
        currentUser != nil
    }

    var shouldShowWelcomeGate: Bool {
        !isCheckingSession && currentUser == nil && !isReaderMode
    }

    func enterAsReader() {
        currentUser = nil
        isReaderMode = true
        pendingAction = nil
        showProtectedAuthSheet = false
        saveState()
    }

    func cancelProtectedAction() {
        pendingAction = nil
        showProtectedAuthSheet = false
        if currentUser == nil {
            isReaderMode = true
        }
        saveState()
    }

    func signIn(emailOrUsername: String, password: String) -> String? {
        let cleanInput = emailOrUsername.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanInput.isEmpty, !cleanPassword.isEmpty else {
            return "Por favor ingresa tu correo o usuario y tu contraseña."
        }

        guard let matchedUser = profiles.first(where: {
            ($0.email.lowercased() == cleanInput || $0.username.lowercased() == cleanInput) &&
            $0.passwordHash == cleanPassword
        }) else {
            return "Correo o contraseña incorrectos. El sistema conserva tus datos para que puedas corregirlos."
        }

        currentUser = matchedUser
        isReaderMode = false
        sessionRestoredBanner = true
        showProtectedAuthSheet = false
        saveState()
        resolvePendingActionIfNeeded()
        return nil
    }

    func registerAccount(name: String, email: String, password: String) -> String? {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanName.count >= 2 else {
            return "El nombre debe tener al menos 2 caracteres."
        }
        guard cleanEmail.contains("@") && cleanEmail.contains(".") else {
            return "Ingresa un correo electrónico con formato válido."
        }
        guard cleanPassword.count >= 4 else {
            return "La contraseña debe tener al menos 4 caracteres."
        }
        guard !profiles.contains(where: { $0.email.lowercased() == cleanEmail }) else {
            return "Este correo electrónico ya está registrado en otra cuenta."
        }

        let words = cleanName.split(separator: " ")
        let initials: String
        if words.count >= 2 {
            initials = String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        } else {
            initials = String(cleanName.prefix(2)).uppercased()
        }

        let baseUsername = cleanEmail.components(separatedBy: "@").first ?? "gamer"
        let newId = UUID()
        let newUser = UserProfile(
            id: newId,
            ownerId: newId,
            name: cleanName,
            username: baseUsername,
            email: cleanEmail,
            passwordHash: cleanPassword,
            initials: initials,
            bio: "Entusiasta de los videojuegos en GameRev.",
            profileType: .player,
            studioOrProject: "",
            creatorRole: "",
            trajectory: "",
            contactURL: "",
            portfolio: []
        )

        profiles.append(newUser)
        categories.append(GameCategory(ownerId: newId, name: "Favoritos", colorHex: "#F5C518"))

        currentUser = newUser
        isReaderMode = false
        showProtectedAuthSheet = false
        saveState()
        resolvePendingActionIfNeeded()
        return nil
    }

    func signOut() {
        currentUser = nil
        isReaderMode = false
        pendingAction = nil
        sessionRestoredBanner = false
        selectedTab = .home
        saveState()
    }

    // MARK: - Ejecución y Recuperación de Acciones Protegidas (Escena 5)
    func requireAuthenticationOrPerform(_ action: PendingAction) {
        if isAuthenticated {
            executeActionImmediately(action)
        } else {
            pendingAction = action
            showProtectedAuthSheet = true
        }
    }

    private func resolvePendingActionIfNeeded() {
        guard let action = pendingAction else { return }
        pendingAction = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.executeActionImmediately(action)
        }
    }

    private func executeActionImmediately(_ action: PendingAction) {
        switch action {
        case .saveToDiary(let game):
            activeDiaryEditorGame = game
        case .openDiary:
            selectedTab = .diary
        case .writeReview(let game):
            activeNewReviewGame = game ?? games.first
            showNewReviewSheet = true
        case .writeComment(let review):
            selectedTab = .reviews
            activeCommentReview = review
        case .openMyProfile:
            selectedTab = .profile
        case .editMyProfile:
            selectedTab = .profile
            showEditMyProfileSheet = true
        }
    }

    // MARK: - Catálogo Global e IGDB (Escena 3 y 4)
    var availableGenres: [String] {
        let all = Set(games.flatMap(\.genres)).sorted()
        return ["Todos"] + all
    }

    var availablePlatforms: [String] {
        let all = Set(games.flatMap(\.platforms)).sorted()
        return ["Todas"] + all
    }

    var availableYears: [Int] {
        Array(Set(games.map(\.releaseYear))).sorted(by: >)
    }

    var featuredGame: Game {
        games.first(where: \.isFeatured) ?? games[0]
    }

    var recentGames: [Game] {
        let mapped = recentGameIds.compactMap { id in games.first(where: { $0.id == id }) }
        return mapped.isEmpty ? Array(games.prefix(4)) : mapped
    }

    func markGameAsVisited(_ game: Game) {
        registerGameIfNeeded(game)
        recentGameIds.removeAll(where: { $0 == game.id })
        recentGameIds.insert(game.id, at: 0)
        if recentGameIds.count > 6 {
            recentGameIds = Array(recentGameIds.prefix(6))
        }
        saveState()
    }

    /// Los juegos que llegan de IGDB no están en `games` hasta que el usuario abre su ficha.
    /// Al registrarlos, el diario y las reseñas pueden referenciarlos como a cualquier otro.
    private func registerGameIfNeeded(_ game: Game) {
        guard !games.contains(where: { $0.id == game.id }) else { return }
        games.append(game)
    }

    // MARK: Secciones de Inicio

    /// Juegos más votados, sin el destacado. Limitado al 30 % del catálogo.
    var trendingGames: [Game] {
        let ranked = games
            .filter { $0.id != featuredGame.id }
            .sorted { $0.votesCount > $1.votesCount }
        return Array(ranked.prefix(homeShelfSize))
    }

    func games(inGenre genre: String) -> [Game] {
        let matches = games
            .filter { $0.genres.contains(where: { $0.caseInsensitiveCompare(genre) == .orderedSame }) }
            .sorted { $0.rating > $1.rating }
        return Array(matches.prefix(homeShelfSize))
    }

    private var homeShelfSize: Int {
        max(4, Int((Double(games.count) * Self.catalogPageFraction).rounded(.up)))
    }

    // MARK: Búsqueda y paginación

    var hasIGDBCredentials: Bool {
        IGDBConfig.resolvedCredentials(manualClientId: igdbClientId, manualToken: igdbBearerToken).isUsable
    }

    var hasActiveCatalogFilters: Bool {
        selectedGenreFilter != "Todos" || selectedPlatformFilter != "Todas" || selectedYearFilter != nil
    }

    var catalogPageSize: Int {
        max(6, Int((Double(catalogResults.count) * Self.catalogPageFraction).rounded(.up)))
    }

    var visibleCatalogResults: [Game] {
        Array(catalogResults.prefix(catalogVisibleCount))
    }

    var hasMoreCatalogResults: Bool {
        catalogVisibleCount < catalogResults.count
    }

    func showMoreCatalogResults() {
        catalogVisibleCount = min(catalogResults.count, catalogVisibleCount + catalogPageSize)
    }

    /// Lanza una búsqueda cancelando la anterior. Con `debounce` espera a que el usuario
    /// deje de escribir, para no enviar una consulta a IGDB por cada tecla.
    func scheduleCatalogSearch(debounce: Bool = false) {
        catalogSearchTask?.cancel()
        catalogSearchTask = Task { [weak self] in
            if debounce {
                try? await Task.sleep(nanoseconds: 350_000_000)
            }
            guard !Task.isCancelled else { return }
            await self?.performCatalogSearch()
        }
    }

    func retryCatalogSearch() {
        simulateNetworkFailure = false
        scheduleCatalogSearch()
    }

    func performCatalogSearch() async {
        isSearchingCatalog = true
        catalogConnectionError = false

        do {
            let outcome = try await IGDBService.shared.searchCatalog(
                query: searchQuery,
                genre: selectedGenreFilter == "Todos" ? nil : selectedGenreFilter,
                platform: selectedPlatformFilter == "Todas" ? nil : selectedPlatformFilter,
                year: selectedYearFilter,
                localCatalog: games,
                simulateFailure: simulateNetworkFailure,
                credentials: IGDBConfig.resolvedCredentials(
                    manualClientId: igdbClientId,
                    manualToken: igdbBearerToken
                )
            )
            // Una búsqueda más nueva ya está en curso: se descarta este resultado.
            guard !Task.isCancelled else { return }

            catalogResults = outcome.games
            catalogSource = outcome.source
            catalogRemoteNotice = outcome.remoteIssue?.shortNotice
            catalogVisibleCount = min(outcome.games.count, catalogPageSize)
        } catch is CancellationError {
            return
        } catch {
            catalogConnectionError = true
        }

        isSearchingCatalog = false
    }

    func clearCatalogFilters() {
        searchQuery = ""
        selectedGenreFilter = "Todos"
        selectedPlatformFilter = "Todas"
        selectedYearFilter = nil
        scheduleCatalogSearch()
    }

    // MARK: - Diario Personal y Categorías (Diagrama 04, Escenas 6 y 7)
    func userCategories(for userId: UUID? = nil) -> [GameCategory] {
        guard let targetId = userId ?? currentUser?.id else { return [] }
        return categories.filter { $0.ownerId == targetId }
    }

    func userDiaryEntries(for userId: UUID? = nil) -> [DiaryEntry] {
        if simulateEmptyDiary && (userId == nil || userId == currentUser?.id) {
            return []
        }
        guard let targetId = userId ?? currentUser?.id else { return [] }
        return diaryEntries
            .filter { $0.userId == targetId }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    var filteredCurrentUserDiaryEntries: [DiaryEntry] {
        let all = userDiaryEntries()
        return all.filter { entry in
            let matchesStatus = diaryStatusFilter == nil || entry.status == diaryStatusFilter
            let matchesCategory = diaryCategoryFilterId == nil || entry.categoryId == diaryCategoryFilterId
            return matchesStatus && matchesCategory
        }
    }

    func existingDiaryEntry(for gameId: UUID) -> DiaryEntry? {
        guard let userId = currentUser?.id else { return nil }
        return diaryEntries.first(where: { $0.userId == userId && $0.gameId == gameId })
    }

    func saveOrUpdateDiaryEntry(
        gameId: UUID,
        status: DiaryStatus,
        categoryId: UUID?,
        note: String,
        personalRating: Int?,
        hoursPlayed: Int = 0
    ) -> String? {
        guard let userId = currentUser?.id else {
            return "Debes iniciar sesión para guardar en tu diario."
        }
        guard games.contains(where: { $0.id == gameId }) else {
            return "Selecciona un videojuego válido."
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if let index = diaryEntries.firstIndex(where: { $0.userId == userId && $0.gameId == gameId }) {
            diaryEntries[index].status = status
            diaryEntries[index].categoryId = categoryId
            diaryEntries[index].personalNote = trimmedNote
            diaryEntries[index].personalRating = personalRating
            diaryEntries[index].hoursPlayed = max(0, hoursPlayed)
            diaryEntries[index].updatedAt = Date()
        } else {
            let newEntry = DiaryEntry(
                userId: userId,
                gameId: gameId,
                status: status,
                categoryId: categoryId,
                personalNote: trimmedNote,
                personalRating: personalRating,
                hoursPlayed: max(0, hoursPlayed),
                updatedAt: Date()
            )
            diaryEntries.insert(newEntry, at: 0)
        }

        simulateEmptyDiary = false
        saveState()
        return nil
    }

    func removeDiaryEntry(_ entryId: UUID) {
        diaryEntries.removeAll(where: { $0.id == entryId })
        saveState()
    }

    func gamesCount(in category: GameCategory) -> Int {
        diaryEntries.filter { $0.userId == category.ownerId && $0.categoryId == category.id }.count
    }

    /// Crea o renombra una categoría y asigna entradas si se especifican (Diagrama 04 y Escena 7).
    func saveCategory(existingId: UUID? = nil, name: String, assignedEntryIds: Set<UUID>? = nil) -> String? {
        guard let userId = currentUser?.id else {
            return "Inicia sesión para gestionar tus categorías."
        }

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "El nombre de la categoría no puede estar vacío."
        }

        let isDuplicate = categories.contains { cat in
            cat.ownerId == userId &&
            cat.id != existingId &&
            cat.name.caseInsensitiveCompare(trimmed) == .orderedSame
        }

        if isDuplicate {
            return "Nombre duplicado"
        }

        let targetCategoryId: UUID
        if let existingId,
           let idx = categories.firstIndex(where: { $0.id == existingId && $0.ownerId == userId }) {
            categories[idx].name = trimmed
            targetCategoryId = existingId
        } else {
            let palette = ["#F5C518", "#3B82F6", "#8B5CF6", "#10B981", "#F43F5E"]
            let color = palette[categories.count % palette.count]
            let newCategory = GameCategory(ownerId: userId, name: trimmed, colorHex: color)
            categories.append(newCategory)
            targetCategoryId = newCategory.id
        }

        if let assignedEntryIds {
            for i in diaryEntries.indices where diaryEntries[i].userId == userId {
                if assignedEntryIds.contains(diaryEntries[i].id) {
                    diaryEntries[i].categoryId = targetCategoryId
                } else if diaryEntries[i].categoryId == targetCategoryId {
                    diaryEntries[i].categoryId = nil
                }
            }
        }

        saveState()
        return nil
    }

    func deleteCategory(_ categoryId: UUID) {
        categories.removeAll(where: { $0.id == categoryId })
        for i in diaryEntries.indices where diaryEntries[i].categoryId == categoryId {
            diaryEntries[i].categoryId = nil
        }
        if diaryCategoryFilterId == categoryId {
            diaryCategoryFilterId = nil
        }
        saveState()
    }

    // MARK: - Reseñas y Comentarios (Diagrama 05 y Escena 8)
    func reviews(for gameId: UUID? = nil) -> [Review] {
        let targetGameId = gameId ?? filterReviewsByGame?.id
        let filtered: [Review]
        if let targetGameId {
            filtered = reviews.filter { $0.gameId == targetGameId }
        } else {
            filtered = reviews
        }
        return filtered.sorted(by: { $0.createdAt > $1.createdAt })
    }

    /// Reseñas más recientes de toda la comunidad, sin depender del filtro de la pestaña Reseñas.
    func recentReviews(limit: Int) -> [Review] {
        Array(reviews.sorted(by: { $0.createdAt > $1.createdAt }).prefix(limit))
    }

    func sortedReviews(gameId: UUID?, by option: ReviewSortOption) -> [Review] {
        let base = gameId.map { id in reviews.filter { $0.gameId == id } } ?? reviews
        switch option {
        case .recent:
            return base.sorted { $0.createdAt > $1.createdAt }
        case .topRated:
            return base.sorted { ($0.rating, $0.createdAt) > ($1.rating, $1.createdAt) }
        case .mostLiked:
            return base.sorted { ($0.likesCount, $0.createdAt) > ($1.likesCount, $1.createdAt) }
        }
    }

    /// Juegos que tienen al menos una reseña, ordenados por título (para el filtro).
    var reviewedGames: [Game] {
        let ids = Set(reviews.map(\.gameId))
        return games.filter { ids.contains($0.id) }.sorted { $0.title < $1.title }
    }

    func comments(for reviewId: UUID) -> [ReviewComment] {
        comments
            .filter { $0.reviewId == reviewId }
            .sorted(by: { $0.createdAt < $1.createdAt })
    }

    func publishReview(gameId: UUID?, rating: Double, title: String = "", text: String) -> String? {
        guard let user = currentUser else {
            return "Inicia sesión para publicar una mini-reseña."
        }
        guard let gameId, games.contains(where: { $0.id == gameId }) else {
            return "Selecciona un videojuego válido."
        }
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return "El texto de la mini-reseña no puede estar vacío."
        }
        guard trimmedText.count <= Self.reviewCharacterLimit else {
            return "La mini-reseña no puede superar los \(Self.reviewCharacterLimit) caracteres."
        }

        let review = Review(
            gameId: gameId,
            authorId: user.id,
            authorUsername: user.username,
            authorName: user.name,
            rating: rating,
            title: trimmedTitle.isEmpty ? "Reseña de \(user.name)" : trimmedTitle,
            text: trimmedText,
            likesCount: 1,
            createdAt: Date()
        )
        reviews.insert(review, at: 0)
        saveState()
        return nil
    }

    func publishComment(reviewId: UUID, text: String) -> String? {
        guard let user = currentUser else {
            return "Inicia sesión para comentar."
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "Escribe un comentario antes de publicar."
        }

        let newComment = ReviewComment(
            reviewId: reviewId,
            authorId: user.id,
            authorUsername: user.username,
            authorName: user.name,
            text: trimmed,
            createdAt: Date()
        )
        comments.append(newComment)
        saveState()
        return nil
    }

    // MARK: - Perfiles, Portafolio y Control de Permisos (Diagramas 06 y 07, Escenas 9, 10 y 11)
    func canEditProfile(_ profile: UserProfile) -> Bool {
        guard let user = currentUser else { return false }
        return user.id == profile.ownerId
    }

    func game(for id: UUID) -> Game? {
        games.first(where: { $0.id == id })
    }

    func creatorProfile(for game: Game) -> UserProfile? {
        if let creatorId = game.creatorProfileId,
           let found = profiles.first(where: { $0.id == creatorId }) {
            return found
        }
        return profiles.first(where: {
            $0.name.caseInsensitiveCompare(game.developerName) == .orderedSame ||
            $0.studioOrProject.caseInsensitiveCompare(game.developerName) == .orderedSame
        })
    }

    func updateOwnProfile(
        targetProfile: UserProfile,
        name: String,
        bio: String,
        profileType: ProfileType,
        studioOrProject: String,
        creatorRole: String,
        trajectory: String,
        contactURL: String,
        portfolio: [PortfolioWork]
    ) -> String? {
        guard canEditProfile(targetProfile),
              let currentId = currentUser?.id,
              let index = profiles.firstIndex(where: { $0.id == currentId }) else {
            unauthorizedBannerVisible = true
            return RecoverableErrorType.unauthorized.title
        }

        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanStudio = studioOrProject.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanRole = creatorRole.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTrajectory = trajectory.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanURL = contactURL.trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanName.count >= 2 else {
            return "El nombre del perfil no puede estar vacío."
        }
        guard !cleanBio.isEmpty else {
            return "Añade una descripción o biografía para tu perfil."
        }

        if profileType == .creator {
            guard !cleanRole.isEmpty else {
                return "Como creador, indica tu rol o especialidad (ej. Artista conceptual, Estudio)."
            }
            guard !cleanTrajectory.isEmpty else {
                return "Añade tu trayectoria o resumen de trabajo."
            }
            if !cleanURL.isEmpty {
                let normalized = cleanURL.lowercased()
                let isValidLink = normalized.hasPrefix("http://") ||
                                  normalized.hasPrefix("https://") ||
                                  normalized.contains(".")
                if !isValidLink {
                    return "El enlace público de contacto no tiene un formato válido."
                }
            }
        }

        profiles[index].name = cleanName
        profiles[index].bio = cleanBio
        profiles[index].profileType = profileType
        profiles[index].studioOrProject = cleanStudio
        profiles[index].creatorRole = cleanRole
        profiles[index].trajectory = cleanTrajectory
        profiles[index].contactURL = cleanURL
        profiles[index].portfolio = portfolio

        currentUser = profiles[index]
        saveState()
        return nil
    }
}
