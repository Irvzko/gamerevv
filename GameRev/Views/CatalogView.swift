//
//  CatalogView.swift
//  GameRev
//
//  Implementa Diagrama 03 y Escena 3 (Catálogo global y consulta a IGDB)
//  incluyendo manejo de error de conexión (CONNECTION_ERROR) y sin resultados (EMPTY_RESULTS).
//
//  La lista se dibuja por tramos del 30 % ("Mostrar más") y con contenedores lazy,
//  de modo que solo se cargan las portadas que realmente están en pantalla.
//

import SwiftUI

struct CatalogView: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: GRSpacing.lg) {
                    searchBar
                    filterBar

                    if let notice = store.catalogRemoteNotice {
                        Button {
                            store.retryCatalogSearch()
                        } label: {
                            InlineNoticeBanner(
                                iconName: "wifi.exclamationmark",
                                text: "\(notice). Mostrando el catálogo local · Toca para reintentar.",
                                tint: .gameRevGoldText
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    content
                }
                .grAdaptiveContent()
                .animation(.easeInOut(duration: 0.2), value: store.catalogVisibleCount)
                .animation(.easeInOut(duration: 0.2), value: store.catalogConnectionError)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: store.simulateNetworkFailure) { _ in
                store.scheduleCatalogSearch()
            }
            .grScreenBackground()
            .navigationTitle("Catálogo")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    labMenu
                }
            }
            .navigationDestination(for: Game.self) { game in
                GameDetailView(game: game)
            }
            .navigationDestination(for: UserProfile.self) { profile in
                PublicProfileView(profile: profile)
            }
        }
    }

    // MARK: - Barra de búsqueda
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Dark Souls, Skyrim, RPG...", text: $store.searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    store.scheduleCatalogSearch()
                }
                .onChange(of: store.searchQuery) { _ in
                    // Espera a que el usuario deje de escribir antes de consultar.
                    store.scheduleCatalogSearch(debounce: true)
                }

            if !store.searchQuery.isEmpty {
                Button {
                    store.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Borrar búsqueda")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.gameRevSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.gameRevStroke, lineWidth: 1)
        )
    }

    // MARK: - Filtros de Género, Plataforma y Año (Escena 3, pág. 7)
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GRSpacing.sm) {
                Menu {
                    ForEach(store.availableGenres, id: \.self) { genre in
                        menuOption(genre, isSelected: store.selectedGenreFilter == genre) {
                            store.selectedGenreFilter = genre
                        }
                    }
                } label: {
                    filterChipLabel(
                        title: store.selectedGenreFilter == "Todos" ? "Género" : store.selectedGenreFilter,
                        isActive: store.selectedGenreFilter != "Todos"
                    )
                }

                Menu {
                    ForEach(store.availablePlatforms, id: \.self) { platform in
                        menuOption(platform, isSelected: store.selectedPlatformFilter == platform) {
                            store.selectedPlatformFilter = platform
                        }
                    }
                } label: {
                    filterChipLabel(
                        title: store.selectedPlatformFilter == "Todas" ? "Plataforma" : store.selectedPlatformFilter,
                        isActive: store.selectedPlatformFilter != "Todas"
                    )
                }

                Menu {
                    menuOption("Todos los años", isSelected: store.selectedYearFilter == nil) {
                        store.selectedYearFilter = nil
                    }
                    ForEach(store.availableYears, id: \.self) { year in
                        menuOption(String(year), isSelected: store.selectedYearFilter == year) {
                            store.selectedYearFilter = year
                        }
                    }
                } label: {
                    filterChipLabel(
                        title: store.selectedYearFilter.map { String($0) } ?? "Año",
                        isActive: store.selectedYearFilter != nil
                    )
                }

                if store.hasActiveCatalogFilters {
                    Button {
                        store.clearCatalogFilters()
                    } label: {
                        Text("Limpiar")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.gameRevLink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func menuOption(_ title: String, isSelected: Bool, select: @escaping () -> Void) -> some View {
        Button {
            select()
            store.scheduleCatalogSearch()
        } label: {
            if isSelected {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }

    private func filterChipLabel(title: String, isActive: Bool) -> some View {
        HStack(spacing: 5) {
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

    // MARK: - Contenido según respuesta de IGDB (Diagrama 03 y Escena 3)
    @ViewBuilder
    private var content: some View {
        if store.catalogConnectionError {
            // NO · ERROR (Escena 3 pág. 8 y Escena 12 CONNECTION_ERROR)
            connectionErrorState
        } else if store.isSearchingCatalog && store.catalogResults.isEmpty {
            loadingState
        } else if store.catalogResults.isEmpty {
            // ¿Hay coincidencias? -> No: Mostrar "Sin resultados" (Escena 12 EMPTY_RESULTS)
            RecoverableErrorCardView(errorType: .emptyResults) {
                store.clearCatalogFilters()
            }
        } else {
            // SÍ · RESULTADOS
            resultsSection
        }
    }

    private var loadingState: some View {
        VStack(alignment: .leading, spacing: GRSpacing.md) {
            Text("Consultando catálogo en IGDB...")
                .grSectionLabel()
            ForEach(0..<5, id: \.self) { _ in
                GameRowSkeletonView()
            }
        }
    }

    private var connectionErrorState: some View {
        VStack(spacing: 14) {
            Text(RecoverableErrorType.connectionError.rawValue)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gameRevDanger.opacity(0.14))
                .foregroundColor(Color.gameRevDanger)
                .clipShape(Capsule())

            Image(systemName: "wifi.slash")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(Color.gameRevDanger)
                .frame(width: 68, height: 68)
                .background(Circle().fill(Color.gameRevDanger.opacity(0.12)))

            Text("No pudimos conectar")
                .font(.system(size: 20, weight: .bold))

            Text("Comprueba tu conexión y vuelve a intentarlo.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                store.retryCatalogSearch()
            } label: {
                if store.isSearchingCatalog {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Reintentar")
                }
            }
            .buttonStyle(GRPrimaryButtonStyle())
            .frame(maxWidth: 240)
            .disabled(store.isSearchingCatalog)
        }
        .frame(maxWidth: .infinity)
        .grCard(padding: 28, radius: 20)
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: GRSpacing.md) {
            HStack(spacing: GRSpacing.sm) {
                Text(resultsTitle)
                    .grSectionLabel()

                if store.isSearchingCatalog {
                    ProgressView()
                        .controlSize(.small)
                }

                Spacer()

                sourceBadge
            }

            LazyVGrid(columns: gridColumns, spacing: GRSpacing.md) {
                ForEach(store.visibleCatalogResults) { game in
                    NavigationLink(value: game) {
                        GameRowCardView(game: game)
                    }
                    .buttonStyle(.plain)
                }
            }
            .opacity(store.isSearchingCatalog ? 0.6 : 1)

            if store.hasMoreCatalogResults {
                Button {
                    store.showMoreCatalogResults()
                } label: {
                    Label("Mostrar más", systemImage: "chevron.down")
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

            Text("Mostrando \(store.visibleCatalogResults.count) de \(store.catalogResults.count) juegos")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var resultsTitle: String {
        if store.searchQuery.isEmpty && !store.hasActiveCatalogFilters {
            return "EXPLORA"
        }
        return "RESULTADOS (\(store.catalogResults.count))"
    }

    private var sourceBadge: some View {
        let isLive = store.catalogSource == .igdb
        let tint: Color = isLive ? .gameRevSuccess : .gameRevLink
        return Text(isLive ? "IGDB EN VIVO" : "IGDB API v4")
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }

    /// Una columna en iPhone; dos o más cuando el ancho lo permite (iPad / Mac).
    private var gridColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [GridItem(.adaptive(minimum: 340), spacing: GRSpacing.md)]
        }
        return [GridItem(.flexible())]
    }

    // MARK: - Menú de pruebas del Lab
    private var labMenu: some View {
        Menu {
            Toggle("Simular fallo de conexión IGDB", isOn: $store.simulateNetworkFailure)
            Button("Buscar \"Dark Souls\"") {
                store.searchQuery = "Dark Souls"
            }
            Button("Probar búsqueda sin resultados") {
                store.searchQuery = "JuegoInexistente999"
            }
            Button("Abrir Inspector del Lab") {
                store.showLabInspectorSheet = true
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}
