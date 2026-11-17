//
//  DiaryView.swift
//  GameRev
//
//  Implementa Diagrama 04, Escena 6 (Consulta y filtrado del diario + Empty State)
//  y Escena 7 (Categorías personalizadas, renombrar, asignar entradas y validación de duplicados).
//

import SwiftUI

struct DiaryView: View {
    @EnvironmentObject var store: AppStateStore

    @State private var showCategoriesSheet: Bool = false
    @State private var editingEntryGame: Game? = nil

    var body: some View {
        NavigationStack {
            Group {
                if !store.isAuthenticated {
                    unauthenticatedDiaryGate
                } else {
                    authenticatedDiaryContent
                }
            }
            .grScreenBackground()
            .navigationTitle("Mi diario")
            .toolbar {
                if store.isAuthenticated {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            showCategoriesSheet = true
                        } label: {
                            Label("Categorías", systemImage: "folder.badge.gearshape")
                        }

                        Button {
                            editingEntryGame = store.games.first
                        } label: {
                            Label("Registrar juego", systemImage: "plus.circle.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCategoriesSheet) {
                CategoriesManagementSheet()
                    .environmentObject(store)
            }
            .sheet(item: $editingEntryGame) { game in
                DiaryEntryEditorSheet(initialGame: game)
                    .environmentObject(store)
            }
        }
    }

    private var unauthenticatedDiaryGate: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.gameRevBlue.opacity(0.12))
                    .frame(width: 76, height: 76)
                Image(systemName: "bookmark.square.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color.gameRevBlue)
            }

            Text("Tu diario personal")
                .font(.system(size: 24, weight: .bold, design: .rounded))

            Text("El diario propio requiere una sesión activa para registrar tus videojuegos, calificarlos y organizarlos por estado y categorías personalizadas.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                store.requireAuthenticationOrPerform(.openDiary)
            } label: {
                Text("Iniciar sesión y abrir mi diario")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.gameRevBlue)
                    )
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(24)
    }

    private var authenticatedDiaryContent: some View {
        let allUserEntries = store.userDiaryEntries()
        let filteredEntries = store.filteredCurrentUserDiaryEntries
        let userCategories = store.userCategories()

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if allUserEntries.isEmpty {
                    emptyDiaryStateView
                } else {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TU COLECCIÓN PERSONAL")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)

                            Text("\(allUserEntries.count) videojuegos registrados")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                        }

                        Spacer()

                        Button {
                            showCategoriesSheet = true
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "tag.fill")
                                Text("Categorías (\(userCategories.count))")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.gameRevBlue.opacity(0.12)))
                            .foregroundColor(Color.gameRevBlue)
                        }
                        .buttonStyle(.plain)
                    }

                    // Filtros de Estado y Categoría
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button {
                                store.diaryStatusFilter = nil
                            } label: {
                                Text("Todos los estados")
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(store.diaryStatusFilter == nil ? Color.gameRevBlue : Color.primary.opacity(0.08)))
                                    .foregroundColor(store.diaryStatusFilter == nil ? .white : .primary)
                            }
                            .buttonStyle(.plain)

                            ForEach(DiaryStatus.allCases) { status in
                                Button {
                                    store.diaryStatusFilter = status
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: status.iconName)
                                            .font(.system(size: 11))
                                        Text(status.rawValue)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(store.diaryStatusFilter == status ? Color.gameRevBlue : Color.primary.opacity(0.08)))
                                    .foregroundColor(store.diaryStatusFilter == status ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button {
                                store.diaryCategoryFilterId = nil
                            } label: {
                                Text("Todas las categorías")
                                    .font(.system(size: 12, weight: .semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Capsule().fill(store.diaryCategoryFilterId == nil ? Color.primary.opacity(0.18) : Color.primary.opacity(0.06)))
                            }
                            .buttonStyle(.plain)

                            ForEach(userCategories) { category in
                                Button {
                                    store.diaryCategoryFilterId = category.id
                                } label: {
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(Color(hex: category.colorHex))
                                            .frame(width: 8, height: 8)
                                        Text(category.name)
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Capsule().fill(store.diaryCategoryFilterId == category.id ? Color.gameRevBlue : Color.primary.opacity(0.06)))
                                    .foregroundColor(store.diaryCategoryFilterId == category.id ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if filteredEntries.isEmpty {
                        RecoverableErrorCardView(
                            errorType: .emptyResults,
                            customDetail: "No tienes videojuegos registrados con esta combinación de estado y categoría."
                        ) {
                            store.diaryStatusFilter = nil
                            store.diaryCategoryFilterId = nil
                        }
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredEntries) { entry in
                                if let game = store.game(for: entry.gameId) {
                                    let categoryName = userCategories.first(where: { $0.id == entry.categoryId })?.name ?? "Sin categoría"
                                    Button {
                                        editingEntryGame = game
                                    } label: {
                                        HStack(spacing: 14) {
                                            GameCoverBadge(
                                                code: game.code,
                                                hexColor: game.coverHex,
                                                imageURL: game.thumbnailImageURL,
                                                width: 56,
                                                height: 78,
                                                cornerRadius: 10,
                                                fontSize: 15
                                            )

                                            VStack(alignment: .leading, spacing: 5) {
                                                HStack {
                                                    Text(game.title)
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                    if let stars = entry.personalRating {
                                                        Text(String(repeating: "★", count: stars))
                                                            .font(.system(size: 12))
                                                            .foregroundColor(Color.gameRevGold)
                                                    }
                                                }

                                                HStack(spacing: 6) {
                                                    Text(entry.status.rawValue)
                                                        .font(.system(size: 11, weight: .bold))
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 3)
                                                        .background(Color.gameRevLink.opacity(0.14))
                                                        .foregroundColor(Color.gameRevLink)
                                                        .clipShape(Capsule())

                                                    Text(categoryName)
                                                        .font(.system(size: 11, weight: .semibold))
                                                        .foregroundColor(.secondary)

                                                    if entry.hoursPlayed > 0 {
                                                        Text("· \(entry.hoursPlayed) h")
                                                            .font(.system(size: 11))
                                                            .foregroundColor(.secondary)
                                                    }
                                                }

                                                if !entry.personalNote.isEmpty {
                                                    Text("\"\(entry.personalNote)\"")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(2)
                                                }
                                            }

                                            Image(systemName: "pencil.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(.secondary.opacity(0.6))
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
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    private var emptyDiaryStateView: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 48)

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
                    .frame(width: 72, height: 72)
                Image(systemName: "doc.text")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
            }

            Text("Tu diario está vacío")
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text("Busca un videojuego en el catálogo y registra\ntu primera aventura")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                store.simulateEmptyDiary = false
                store.selectedTab = .catalog
            } label: {
                Text("Buscar videojuegos")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 26)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.gameRevBlue)
                    )
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 48)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}

// MARK: - Hoja de Registro / Edición de Entrada del Diario (Diagrama 04)
struct DiaryEntryEditorSheet: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.dismiss) private var dismiss

    let initialGame: Game

    @State private var selectedGameId: UUID
    @State private var selectedStatus: DiaryStatus = .playing
    @State private var selectedCategoryId: UUID? = nil
    @State private var personalNote: String = ""
    @State private var personalRating: Int = 5
    @State private var hoursPlayed: Int = 15
    @State private var errorMessage: String? = nil

    init(initialGame: Game) {
        self.initialGame = initialGame
        _selectedGameId = State(initialValue: initialGame.id)
    }

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Section {
                        RecoverableErrorCardView(errorType: .invalidForm, customDetail: errorMessage) {
                            self.errorMessage = nil
                        }
                    }
                }

                Section("Videojuego") {
                    Picker("Juego", selection: $selectedGameId) {
                        ForEach(store.games) { game in
                            Text(game.title).tag(game.id)
                        }
                    }
                    .onChange(of: selectedGameId) { newId in
                        loadExistingEntry(for: newId)
                    }
                }

                Section("Estado en tu Diario") {
                    Picker("Estado actual", selection: $selectedStatus) {
                        ForEach(DiaryStatus.allCases) { status in
                            Label(status.rawValue, systemImage: status.iconName)
                                .tag(status)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Categoría Personalizada") {
                    Picker("Categoría", selection: $selectedCategoryId) {
                        Text("Sin categoría").tag(UUID?.none)
                        ForEach(store.userCategories()) { category in
                            Text(category.name).tag(UUID?.some(category.id))
                        }
                    }
                }

                Section("Tu Calificación, Horas y Nota") {
                    Stepper("Tu calificación: \(personalRating) / 5 ★", value: $personalRating, in: 1...5)
                    Stepper("Horas jugadas: \(hoursPlayed) h", value: $hoursPlayed, in: 0...2000, step: 5)
                    TextField("Escribe tus notas, progreso o impresiones...", text: $personalNote, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let existing = store.existingDiaryEntry(for: selectedGameId) {
                    Section {
                        Button(role: .destructive) {
                            store.removeDiaryEntry(existing.id)
                            dismiss()
                        } label: {
                            Label("Eliminar entrada de mi diario", systemImage: "trash")
                        }
                    }
                }
            }
            .grScreenBackground()
            .navigationTitle("Entrada del diario")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if let error = store.saveOrUpdateDiaryEntry(
                            gameId: selectedGameId,
                            status: selectedStatus,
                            categoryId: selectedCategoryId,
                            note: personalNote,
                            personalRating: personalRating,
                            hoursPlayed: hoursPlayed
                        ) {
                            errorMessage = error
                        } else {
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadExistingEntry(for: selectedGameId)
            }
        }
    }

    private func loadExistingEntry(for gameId: UUID) {
        if let existing = store.existingDiaryEntry(for: gameId) {
            selectedStatus = existing.status
            selectedCategoryId = existing.categoryId
            personalNote = existing.personalNote
            personalRating = existing.personalRating ?? 5
            hoursPlayed = existing.hoursPlayed
        } else {
            selectedStatus = .playing
            selectedCategoryId = store.userCategories().first?.id
            personalNote = ""
            personalRating = 5
            hoursPlayed = 10
        }
    }
}

// MARK: - Escena 7 y Diagrama 04 · Gestión de Categorías y Asignación de Entradas
struct CategoriesManagementSheet: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.dismiss) private var dismiss

    @State private var showCreateForm: Bool = false
    @State private var editingCategory: GameCategory? = nil
    @State private var categoryNameInput: String = ""
    @State private var assignedEntryIds: Set<UUID> = []
    @State private var validationError: String? = nil

    var body: some View {
        NavigationStack {
            if showCreateForm {
                categoryFormView
            } else {
                categoriesListView
            }
        }
    }

    private var categoriesListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ORGANIZA TU DIARIO")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    Text("Mis categorías")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }

                VStack(spacing: 10) {
                    ForEach(store.userCategories()) { category in
                        Button {
                            openEditor(for: category)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(hex: category.colorHex))
                                    .frame(width: 10, height: 10)

                                Text(category.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("\(store.gamesCount(in: category)) juegos")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)

                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundColor(Color.gameRevLink)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.gameRevSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    openEditor(for: nil)
                } label: {
                    Text("+ Nueva categoría")
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
            .padding(24)
        }
        .grScreenBackground()
        .navigationTitle("Categorías")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Listo") { dismiss() }
            }
        }
    }

    private var categoryFormView: some View {
        let userEntries = store.userDiaryEntries()
        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(editingCategory == nil ? "Crear categoría" : "Renombrar y asignar entradas")
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre de categoría")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    TextField("Ej. Indies favoritos", text: $categoryNameInput)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(validationError != nil ? Color.gameRevDanger.opacity(0.08) : Color.primary.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(validationError != nil ? Color.gameRevDanger.opacity(0.45) : Color.clear, lineWidth: 1.5)
                                )
                        )
                        .onChange(of: categoryNameInput) { _ in
                            if validationError != nil {
                                validationError = nil
                            }
                        }

                    if let validationError {
                        HStack(spacing: 6) {
                            Text("×")
                                .font(.system(size: 16, weight: .bold))
                            Text(validationError)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Color.gameRevDanger)
                    }
                }

                // Diagrama 04: "Crear o renombrar categoría; asignar entradas"
                if !userEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Asignar entradas de tu diario a esta categoría")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)

                        ForEach(userEntries) { entry in
                            if let game = store.game(for: entry.gameId) {
                                let isSelected = assignedEntryIds.contains(entry.id)
                                Button {
                                    if isSelected {
                                        assignedEntryIds.remove(entry.id)
                                    } else {
                                        assignedEntryIds.insert(entry.id)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                            .foregroundColor(isSelected ? Color.gameRevLink : .secondary)
                                        Text(game.title)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(entry.status.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.gameRevSurface)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                VStack(spacing: 12) {
                    Button {
                        if let error = store.saveCategory(
                            existingId: editingCategory?.id,
                            name: categoryNameInput,
                            assignedEntryIds: assignedEntryIds
                        ) {
                            validationError = error
                        } else {
                            showCreateForm = false
                        }
                    } label: {
                        Text("Guardar categoría")
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

                    if let editingCategory {
                        Button(role: .destructive) {
                            store.deleteCategory(editingCategory.id)
                            showCreateForm = false
                        } label: {
                            Text("Eliminar categoría")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.gameRevDanger)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        showCreateForm = false
                    } label: {
                        Text("Cancelar")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.primary.opacity(0.05))
                            )
                            .foregroundColor(Color.gameRevBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
        .grScreenBackground()
        .navigationTitle(editingCategory == nil ? "Nueva categoría" : "Editar categoría")
    }

    private func openEditor(for category: GameCategory?) {
        editingCategory = category
        categoryNameInput = category?.name ?? ""
        validationError = nil
        if let category {
            let matching = store.userDiaryEntries().filter { $0.categoryId == category.id }.map(\.id)
            assignedEntryIds = Set(matching)
        } else {
            assignedEntryIds = []
        }
        showCreateForm = true
    }
}
