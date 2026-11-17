//
//  GameDetailView.swift
//  GameRev
//
//  Ficha de videojuego estilo IMDb con portada oficial, banner, valoración global,
//  Metascore, plataformas, créditos de talento/creadores y reseñas con hilo de comentarios.
//

import SwiftUI

struct GameDetailView: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let game: Game

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                imdbHeroHeader

                if horizontalSizeClass == .regular {
                    HStack(alignment: .top, spacing: 28) {
                        VStack(alignment: .leading, spacing: 22) {
                            synopsisAndMetadataSection
                            creditsSection
                            communityReviewsSection
                        }
                        .frame(maxWidth: .infinity)

                        actionPanelSidebar
                            .frame(width: 320)
                    }
                    .padding(.horizontal, 28)
                } else {
                    VStack(alignment: .leading, spacing: 22) {
                        actionButtonsStack
                        synopsisAndMetadataSection
                        creditsSection
                        communityReviewsSection
                    }
                    .padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 32)
        }
        .grScreenBackground()
        .navigationTitle(game.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            store.markGameAsVisited(game)
        }
    }

    // MARK: - Cabecera Estilo IMDb (Banner + Póster + Calificación ★ + Metascore)
    private var imdbHeroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteFillImage(urlString: game.bannerImageURL, fallbackHex: game.coverHex)
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.2), Color.gameRevNavy.opacity(0.96)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .clipped()

            HStack(
                alignment: .bottom,
                spacing: horizontalSizeClass == .regular ? 18 : 12
            ) {
                GameCoverBadge(
                    code: game.code,
                    hexColor: game.coverHex,
                    imageURL: game.thumbnailImageURL,
                    width: horizontalSizeClass == .regular ? 112 : 84,
                    height: horizontalSizeClass == .regular ? 158 : 119,
                    cornerRadius: horizontalSizeClass == .regular ? 14 : 11,
                    fontSize: horizontalSizeClass == .regular ? 28 : 22
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: horizontalSizeClass == .regular ? 14 : 11,
                        style: .continuous
                    )
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(game.developerName.uppercased()) · \(game.releaseYearText)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.gameRevGold)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(game.title)
                        .font(
                            .system(
                                size: horizontalSizeClass == .regular ? 26 : 22,
                                weight: .heavy,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text(game.genresFormatted)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(horizontalSizeClass == .regular ? nil : 1)
                        .truncationMode(.tail)

                    // Barra de Calificación IMDb + Metascore
                    HStack(spacing: horizontalSizeClass == .regular ? 16 : 8) {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.gameRevGold)
                            Text(game.ratingText)
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(.white)
                            Text("/ 5")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }

                        Text(game.votesText)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        if game.hasMetascore {
                            MetascoreBadge(score: game.metascore)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            }
            .padding(horizontalSizeClass == .regular ? 20 : 16)
        }
    }

    // MARK: - Botones de Acción Programables (Diagrama 03 y Escena 4)
    private var actionButtonsStack: some View {
        VStack(spacing: 10) {
            Button {
                store.requireAuthenticationOrPerform(.saveToDiary(game))
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: existingEntry != nil ? "checkmark.circle.fill" : "plus.rectangle.on.folder.fill")
                    Text(existingEntry != nil ? "En mi diario (\(existingEntry!.status.rawValue)) · Editar" : "+ Guardar en mi diario")
                }
                .font(.system(size: 15, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.gameRevGold)
                )
                .foregroundColor(.black)
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                writeReviewButton

                if let creator = store.creatorProfile(for: game) {
                    creatorButton(for: creator)
                }
            }
        }
    }

    private var writeReviewButton: some View {
        Button {
            store.requireAuthenticationOrPerform(.writeReview(game))
        } label: {
            Label("Escribir reseña", systemImage: "square.and.pencil")
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.gameRevBlue)
                )
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }

    private func creatorButton(for creator: UserProfile) -> some View {
        NavigationLink(value: creator) {
            Label("Ver creador", systemImage: "person.text.rectangle")
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                )
                .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }

    private var actionPanelSidebar: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ACCIONES DEL JUEGO")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)

            actionButtonsStack

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("FICHA TÉCNICA")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                metadataRow(label: "Desarrollador", value: game.developerName)
                metadataRow(label: "Distribuidor", value: game.publisherName)
                metadataRow(label: "Lanzamiento", value: game.releaseYearText)
                metadataRow(label: "Modo de juego", value: game.gameMode)
                metadataRow(label: "Plataformas", value: game.platformsFormatted)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.gameRevSurface)
        )
    }

    private func metadataRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Sinopsis y Metadatos
    private var synopsisAndMetadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !game.tagline.isEmpty {
                Text("\"\(game.tagline)\"")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .italic()
                    .foregroundColor(.secondary)
            }

            Text("SINOPSIS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)

            Text(game.synopsis)
                .font(.system(size: 15))
                .lineSpacing(4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(game.platforms, id: \.self) { plat in
                        Text(plat)
                            .font(.system(size: 11, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.primary.opacity(0.07)))
                    }
                }
            }
        }
    }

    // MARK: - Créditos y Creadores Detrás de la Obra (Visibilidad del Talento Indie)
    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TALENTO Y CREADORES DETRÁS DE LA OBRA")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)

            if let mainCreator = store.creatorProfile(for: game) {
                NavigationLink(value: mainCreator) {
                    HStack(spacing: 14) {
                        AvatarCircleBadge(initials: mainCreator.initials, size: 48, fontSize: 16)
                        VStack(alignment: .leading, spacing: 3) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mainCreator.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                Text(mainCreator.roleBadgeText)
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gameRevLink.opacity(0.15))
                                    .foregroundColor(Color.gameRevLink)
                                    .clipShape(Capsule())
                            }
                            Text(mainCreator.bio)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
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

            ForEach(game.credits) { credit in
                if let profile = store.profiles.first(where: { $0.id == credit.profileId }),
                   profile.id != game.creatorProfileId {
                    NavigationLink(value: profile) {
                        HStack(spacing: 12) {
                            AvatarCircleBadge(initials: profile.initials, size: 40, fontSize: 13)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(credit.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.primary)
                                Text(credit.role)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.gameRevLink)
                            }
                            Spacer()
                            Text("Ver portafolio →")
                                .font(.caption.weight(.semibold))
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
    }

    // MARK: - Reseñas de Usuarios y Comentarios en la Ficha
    private var communityReviewsSection: some View {
        let gameReviews = store.reviews(for: game.id)
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("RESEÑAS DE LA COMUNIDAD (\(gameReviews.count))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Button("+ Escribir reseña") {
                    store.requireAuthenticationOrPerform(.writeReview(game))
                }
                .font(.caption.weight(.bold))
                .foregroundColor(Color.gameRevLink)
                .buttonStyle(.plain)
            }

            if gameReviews.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Aún no hay reseñas para \(game.title).")
                        .font(.system(size: 14, weight: .semibold))
                    Button("Sé la primera persona en escribir una mini-reseña →") {
                        store.requireAuthenticationOrPerform(.writeReview(game))
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.gameRevLink)
                    .buttonStyle(.plain)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.gameRevSurface)
                )
            } else {
                ForEach(gameReviews) { review in
                    let commentList = store.comments(for: review.id)
                    NavigationLink(destination: ReviewDetailView(review: review)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("@\(review.authorUsername)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.gameRevLink)
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color.gameRevGold)
                                    Text(String(format: "%.1f / 5", review.rating))
                                        .font(.system(size: 12, weight: .bold))
                                }
                            }

                            if !review.title.isEmpty {
                                Text(review.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.primary)
                            }

                            Text(review.text)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)

                            HStack(spacing: 12) {
                                Label("\(commentList.count) comentario\(commentList.count == 1 ? "" : "s")", systemImage: "bubble.left.and.bubble.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Color.gameRevLink)
                                Spacer()
                                Text("Participar en el hilo →")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.gameRevSurface)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var existingEntry: DiaryEntry? {
        store.existingDiaryEntry(for: game.id)
    }
}
