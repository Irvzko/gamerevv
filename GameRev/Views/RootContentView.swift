//
//  RootContentView.swift
//  GameRev
//
//  Contenedor raíz que coordina la Escena 1 (Arranque y Session Check),
//  la Escena 2 (Navegación adaptativa TabView / NavigationSplitView) y
//  las hojas modales globales de recuperación de acción protegida (Escena 5).
//

import SwiftUI

struct RootContentView: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if store.isCheckingSession {
                SplashSessionCheckView()
            } else if store.shouldShowWelcomeGate {
                WelcomeGateView()
            } else {
                adaptiveNavigationShell
            }
        }
        .task {
            await store.performInitialSessionCheck()
        }
        // Escena 5: Hoja de Acceso Requerido que conserva pendingAction
        .sheet(isPresented: $store.showProtectedAuthSheet) {
            ProtectedActionGateSheet()
                .environmentObject(store)
        }
        // Hoja global para guardar en el diario (incluyendo tras recuperar pendingAction)
        .sheet(item: $store.activeDiaryEditorGame) { game in
            DiaryEntryEditorSheet(initialGame: game)
                .environmentObject(store)
        }
        // Hoja global para escribir mini-reseña (incluyendo tras recuperar pendingAction)
        .sheet(isPresented: $store.showNewReviewSheet) {
            NewReviewSheet(initialGame: store.activeNewReviewGame)
                .environmentObject(store)
        }
        // Hoja global para editar perfil propio (Escena 10)
        .sheet(isPresented: $store.showEditMyProfileSheet) {
            EditProfileSheet()
                .environmentObject(store)
        }
        // Inspector del Laboratorio iOS (Escenas 01 a 13)
        .sheet(isPresented: $store.showLabInspectorSheet) {
            LabInspectorSheetView()
                .environmentObject(store)
        }
    }

    // MARK: - Escena 2 · Navegación Adaptativa (TabView en iPhone / NavigationSplitView en MacBook e iPad)
    @ViewBuilder
    private var adaptiveNavigationShell: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                VStack(alignment: .leading, spacing: 8) {
                    // Cabecera de Sidebar estilo MacBook (Escena 2, pág. 6)
                    HStack(spacing: 10) {
                        Text("GR")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(Color.gameRevGold)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.gameRevNavy)
                            )
                        Text("GameRev")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    List {
                        ForEach(MainTab.allCases) { tab in
                            Button {
                                store.selectedTab = tab
                            } label: {
                                Label(tab.rawValue, systemImage: tab.iconName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(
                                store.selectedTab == tab
                                    ? Color.gameRevBlue.opacity(0.15)
                                    : Color.clear
                            )
                        }
                    }
                    .listStyle(.sidebar)

                    // Estado de sesión en la parte inferior del Sidebar
                    VStack(alignment: .leading, spacing: 6) {
                        Divider()
                        HStack(spacing: 10) {
                            AvatarCircleBadge(
                                initials: store.currentUser?.initials ?? "LC",
                                size: 34,
                                fontSize: 12
                            )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.currentUser?.name ?? "Modo Lector")
                                    .font(.system(size: 13, weight: .semibold))
                                    .lineLimit(1)
                                Text(store.isAuthenticated ? "Sesión activa" : "Consulta pública")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                store.showLabInspectorSheet = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 13))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                }
                .navigationSplitViewColumnWidth(min: 210, ideal: 235, max: 270)
            } detail: {
                activeTabDestinationView
            }
        } else {
            TabView(selection: $store.selectedTab) {
                ForEach(MainTab.allCases) { tab in
                    tabContent(for: tab)
                        .tabItem {
                            Label(tab.rawValue, systemImage: tab.iconName)
                        }
                        .tag(tab)
                }
            }
            .tint(Color.gameRevBlue)
        }
    }

    @ViewBuilder
    private var activeTabDestinationView: some View {
        tabContent(for: store.selectedTab)
    }

    @ViewBuilder
    private func tabContent(for tab: MainTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .catalog:
            CatalogView()
        case .diary:
            DiaryView()
        case .reviews:
            ReviewsView()
        case .profile:
            ProfileTabRootView()
        }
    }
}
