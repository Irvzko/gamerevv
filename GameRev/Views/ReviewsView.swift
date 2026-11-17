//
//  ReviewsView.swift
//  GameRev
//
//  Implementa Diagrama 05 y Escena 8 (Mini-reseñas, validación de texto no vacío
//  y Detalle de reseña con su hilo de comentarios).
//

import SwiftUI

struct ReviewsView: View {
    @EnvironmentObject var store: AppStateStore

    @State private var navigationPath = NavigationPath()
    @State private var sortOption: ReviewSortOption = .recent
    /// Tramos adicionales cargados con "Ver más reseñas".
    @State private var extraPages = 0

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: GRSpacing.lg) {
                    summaryHeader
                    controlsBar

                    if allReviews.isEmpty {
                        emptyState
                    } else {
                        ForEach(visibleReviews) { review in
                            NavigationLink(value: review) {
                                ReviewCardView(review: review)
                            }
                            .buttonStyle(.plain)
                        }

                        if visibleReviews.count < allReviews.count {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    extraPages += 1
                                }
                            } label: {
                                Label("Ver más reseñas", systemImage: "chevron.down")
                                    .font(.system(size: 15, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.gameRevBlue.opacity(0.12))
                                    )
                                    .foregroundColor(Color.gameRevLink)
                            }
                            .buttonStyle(.plain)
                        }

                        Text("Mostrando \(visibleReviews.count) de \(allReviews.count) reseñas")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .grAdaptiveContent(maxWidth: 760)
            }
            .grScreenBackground()
            .navigationTitle("Reseñas")
            .navigationDestination(for: Review.self) { review in
                ReviewDetailView(review: review)
            }
            // Botón principal "Escribir reseña" (Escena 8, pág. 17), siempre a mano.
            .safeAreaInset(edge: .bottom) {
                Button("Escribir reseña") {
                    store.requireAuthenticationOrPerform(.writeReview(store.filterReviewsByGame))
                }
                .buttonStyle(GRPrimaryButtonStyle())
                .frame(maxWidth: 520)
                .padding(.horizontal, GRSpacing.lg)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
            .onChange(of: store.filterReviewsByGame) { _ in
                extraPages = 0
            }
            .onChange(of: sortOption) { _ in
                extraPages = 0
            }
            .onChange(of: store.activeCommentReview) { _ in
                openPendingCommentIfNeeded()
            }
            .onAppear {
                openPendingCommentIfNeeded()
            }
        }
    }

    // MARK: - Datos
    private var allReviews: [Review] {
        store.sortedReviews(gameId: store.filterReviewsByGame?.id, by: sortOption)
    }

    /// Tamaño de tramo: 30 % de las reseñas, con un mínimo cómodo de lectura.
    private var pageSize: Int {
        max(5, Int((Double(allReviews.count) * AppStateStore.catalogPageFraction).rounded(.up)))
    }

    private var visibleReviews: [Review] {
        Array(allReviews.prefix(pageSize * (extraPages + 1)))
    }

    private var averageRatingText: String {
        guard !allReviews.isEmpty else { return "—" }
        let total = allReviews.reduce(0) { $0 + $1.rating }
        return String(format: "%.1f", total / Double(allReviews.count))
    }

    /// Tras iniciar sesión para comentar (acción pendiente), abre la reseña correspondiente.
    private func openPendingCommentIfNeeded() {
        guard let review = store.activeCommentReview else { return }
        store.activeCommentReview = nil
        // Si ya hay una reseña abierta (el caso habitual), no se apila otra pantalla.
        if navigationPath.isEmpty {
            navigationPath.append(review)
        }
    }

    // MARK: - Secciones
    private var summaryHeader: some View {
        HStack(spacing: GRSpacing.lg) {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.filterReviewsByGame?.title ?? "Toda la comunidad")
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(2)
                Text("\(allReviews.count) mini-reseña\(allReviews.count == 1 ? "" : "s")")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: GRSpacing.sm)

            VStack(alignment: .trailing, spacing: 2) {
                StarRatingLabel(text: averageRatingText, size: 20)
                Text("promedio")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .grCard()
    }

    private var controlsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GRSpacing.sm) {
                Menu {
                    Button {
                        store.filterReviewsByGame = nil
                    } label: {
                        if store.filterReviewsByGame == nil {
                            Label("Todos los juegos", systemImage: "checkmark")
                        } else {
                            Text("Todos los juegos")
                        }
                    }
                    ForEach(store.reviewedGames) { game in
                        Button {
                            store.filterReviewsByGame = game
                        } label: {
                            if store.filterReviewsByGame?.id == game.id {
                                Label(game.title, systemImage: "checkmark")
                            } else {
                                Text(game.title)
                            }
                        }
                    }
                } label: {
                    chipLabel(
                        iconName: "gamecontroller",
                        title: store.filterReviewsByGame?.title ?? "Todos los juegos",
                        isActive: store.filterReviewsByGame != nil
                    )
                }

                Menu {
                    ForEach(ReviewSortOption.allCases) { option in
                        Button {
                            sortOption = option
                        } label: {
                            Label(option.rawValue, systemImage: sortOption == option ? "checkmark" : option.iconName)
                        }
                    }
                } label: {
                    chipLabel(iconName: "arrow.up.arrow.down", title: sortOption.rawValue, isActive: false)
                }
            }
        }
    }

    private func chipLabel(iconName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .semibold))
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
            Image(systemName: "chevron.down")
                .font(.system(size: 10, weight: .bold))
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(isActive ? Color.gameRevBlue : Color.gameRevSurface)
        )
        .overlay(
            Capsule()
                .strokeBorder(isActive ? Color.clear : Color.gameRevStroke, lineWidth: 1)
        )
        .foregroundColor(isActive ? .white : .primary)
    }

    /// Diagrama 05: "Si aún no hay reseñas, ofrecer escribir la primera o continuar consultando."
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "text.bubble")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("Aún no hay mini-reseñas para este filtro")
                .font(.system(size: 17, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Sé la primera persona en compartir tu análisis con la comunidad o continúa explorando otros títulos.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .grCard(padding: 28, radius: 18)
    }
}

// MARK: - Tarjeta de Reseña (lista de Reseñas e Inicio)
struct ReviewCardView: View {
    @EnvironmentObject var store: AppStateStore

    let review: Review
    var showsGame: Bool = true
    var textLineLimit: Int? = 5

    var body: some View {
        let commentCount = store.comments(for: review.id).count

        VStack(alignment: .leading, spacing: GRSpacing.md) {
            if showsGame, let game = store.game(for: review.gameId) {
                HStack(spacing: GRSpacing.md) {
                    GameCoverBadge(game: game, width: 42, height: 60, cornerRadius: 8, fontSize: 13)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Text(game.primaryGenreAndYear)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: GRSpacing.sm)

                    ReviewRatingPill(rating: review.rating)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                if !review.title.isEmpty {
                    Text(review.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }

                Text(review.text)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                    .lineLimit(textLineLimit)
                    .multilineTextAlignment(.leading)
            }

            HStack(spacing: GRSpacing.sm) {
                AvatarCircleBadge(initials: authorInitials, size: 28, fontSize: 10)

                VStack(alignment: .leading, spacing: 1) {
                    Text("@\(review.authorUsername)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(review.createdAt.formatted(.relative(presentation: .named)))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: GRSpacing.sm)

                if !showsGame {
                    ReviewRatingPill(rating: review.rating)
                }

                Label("\(review.likesCount)", systemImage: "hand.thumbsup")
                    .accessibilityLabel("\(review.likesCount) votos útiles")
                Label("\(commentCount)", systemImage: "bubble.right")
                    .accessibilityLabel("\(commentCount) comentario\(commentCount == 1 ? "" : "s")")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.gameRevLink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .grCard()
    }

    private var authorInitials: String {
        store.profiles.first(where: { $0.id == review.authorId })?.initials
            ?? String(review.authorUsername.prefix(2)).uppercased()
    }
}

struct ReviewRatingPill: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
            Text(String(format: "%.1f", rating))
                .font(.system(size: 13, weight: .bold))
        }
        .foregroundColor(Color.gameRevGoldText)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.gameRevGold.opacity(0.18)))
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Valoración \(String(format: "%.1f", rating)) de 5")
    }
}

// MARK: - Escena 8 · Formulario "Nueva reseña" con Contador y Validación (pág. 17 derecha)
struct NewReviewSheet: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.dismiss) private var dismiss

    let initialGame: Game?

    @State private var selectedGameId: UUID
    @State private var rating: Double = 4.5
    @State private var reviewTitle: String = ""
    @State private var reviewText: String = ""
    @State private var errorMessage: String? = nil

    private let characterLimit = AppStateStore.reviewCharacterLimit

    init(initialGame: Game?) {
        self.initialGame = initialGame
        let defaultId = initialGame?.id ?? SeedData.celesteId
        _selectedGameId = State(initialValue: defaultId)
    }

    private var isOverLimit: Bool {
        reviewText.count > characterLimit
    }

    private var canPublish: Bool {
        !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOverLimit
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Cabecera del juego seleccionado
                    if let selectedGame = store.game(for: selectedGameId) {
                        HStack(spacing: 14) {
                            GameCoverBadge(game: selectedGame, width: 48, height: 68, cornerRadius: 10, fontSize: 15)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(selectedGame.title)
                                    .font(.system(size: 17, weight: .bold))
                                    .lineLimit(2)
                                Text(selectedGame.primaryGenreAndYear)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer(minLength: 0)
                        }
                        .grCard(padding: 14)
                    }

                    Picker("Cambiar videojuego", selection: $selectedGameId) {
                        ForEach(store.games.sorted { $0.title < $1.title }) { game in
                            Text(game.title).tag(game.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.gameRevLink)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Valoración")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                            ReviewRatingPill(rating: rating)
                        }
                        Slider(value: $rating, in: 1.0...5.0, step: 0.1)
                            .tint(Color.gameRevGold)
                    }

                    if let errorMessage {
                        RecoverableErrorCardView(errorType: .invalidForm, customDetail: errorMessage) {
                            self.errorMessage = nil
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título (opcional)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)

                        TextField("Resume tu opinión en una frase", text: $reviewTitle)
                            .padding(14)
                            .background(fieldBackground)
                    }

                    // Campo de mini-reseña con contador (Escena 8, pág. 17)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tu mini-reseña")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)

                        TextField("Una experiencia precisa y emotiva...", text: $reviewText, axis: .vertical)
                            .lineLimit(4...8)
                            .padding(14)
                            .background(fieldBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(isOverLimit ? Color.gameRevDanger : Color.clear, lineWidth: 1.5)
                            )
                            .onChange(of: reviewText) { _ in
                                if errorMessage != nil {
                                    errorMessage = nil
                                }
                            }

                        HStack {
                            if isOverLimit {
                                Text("Te pasaste por \(reviewText.count - characterLimit)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color.gameRevDanger)
                            }
                            Spacer()
                            Text("\(reviewText.count) / \(characterLimit)")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(isOverLimit ? Color.gameRevDanger : .secondary)
                        }
                    }

                    Button("Publicar") {
                        publish()
                    }
                    .buttonStyle(GRPrimaryButtonStyle())
                    .opacity(canPublish ? 1 : 0.5)
                }
                .padding(20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .grScreenBackground()
            .navigationTitle("Nueva reseña")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.gameRevSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.gameRevStroke, lineWidth: 1)
            )
    }

    /// El botón no se deshabilita: si el texto está vacío, la validación del store
    /// devuelve el mensaje INVALID_FORM que pide la Escena 8.
    private func publish() {
        if let error = store.publishReview(
            gameId: selectedGameId,
            rating: rating,
            title: reviewTitle,
            text: reviewText
        ) {
            errorMessage = error
        } else {
            dismiss()
        }
    }
}

// MARK: - Escena 8 · Detalle de Reseña y Comentarios en Hilo (pág. 18)
struct ReviewDetailView: View {
    @EnvironmentObject var store: AppStateStore

    let review: Review

    @State private var commentInput: String = ""
    @State private var commentError: String? = nil

    var body: some View {
        let reviewComments = store.comments(for: review.id)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Publicación principal con barra vertical de acento (Escena 8, pág. 18)
                ReviewCardView(review: review, textLineLimit: nil)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gameRevBlue)
                            .frame(width: 4)
                            .padding(.vertical, 14)
                    }

                // Hilo de Comentarios
                VStack(alignment: .leading, spacing: GRSpacing.md) {
                    Text("COMENTARIOS (\(reviewComments.count))")
                        .grSectionLabel()

                    if reviewComments.isEmpty {
                        Text("Todavía nadie ha comentado. Abre tú la conversación.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    ForEach(reviewComments) { comment in
                        HStack(alignment: .top, spacing: GRSpacing.md) {
                            AvatarCircleBadge(
                                initials: String(comment.authorName.prefix(1)).uppercased(),
                                size: 30,
                                fontSize: 12
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text("@\(comment.authorUsername)")
                                        .font(.system(size: 13, weight: .bold))
                                        .lineLimit(1)
                                    Spacer(minLength: GRSpacing.sm)
                                    Text(comment.createdAt.formatted(.relative(presentation: .named)))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Text(comment.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .grCard(padding: 14, radius: 14)
                    }
                }

                if let commentError {
                    RecoverableErrorCardView(errorType: .invalidForm, customDetail: commentError) {
                        self.commentError = nil
                    }
                }

                // Formulario para añadir comentario (Escena 8, pág. 18)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Añadir comentario")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    TextField("Totalmente de acuerdo...", text: $commentInput, axis: .vertical)
                        .lineLimit(2...5)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.gameRevSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.gameRevStroke, lineWidth: 1)
                        )
                        .onChange(of: commentInput) { _ in
                            if commentError != nil {
                                commentError = nil
                            }
                        }

                    Button("Comentar") {
                        handlePostComment()
                    }
                    .buttonStyle(GRPrimaryButtonStyle())
                }
            }
            .grAdaptiveContent(maxWidth: 760)
        }
        .scrollDismissesKeyboard(.interactively)
        .grScreenBackground()
        .navigationTitle("Detalle de reseña")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func handlePostComment() {
        guard store.isAuthenticated else {
            store.requireAuthenticationOrPerform(.writeComment(review))
            return
        }

        if let error = store.publishComment(reviewId: review.id, text: commentInput) {
            commentError = error
        } else {
            commentInput = ""
            commentError = nil
        }
    }
}
