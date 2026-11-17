//
//  GameRevApp.swift
//  GameRev
//
//  Punto de entrada principal de la aplicación GameRev para iOS y macOS.
//  Lab iOS Ago-Dic 2026 · Equipo 6
//  Profesor: Azael Flores
//

import SwiftUI

@main
struct GameRevApp: App {
    @StateObject private var store = AppStateStore()

    init() {
        // Tope de memoria para las portadas descargadas (AsyncImage usa esta caché).
        // Lo que no cabe en memoria se relee del disco en lugar de volver a la red.
        URLCache.shared = URLCache(
            memoryCapacity: 24 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
    }

    var body: some Scene {
        WindowGroup {
            RootContentView()
                .environmentObject(store)
        }
    }
}
