//
//  IGDBConfig.swift
//  GameRev
//
//  Lectura de credenciales de IGDB / Twitch sin escribirlas en el código.
//
//  Orden de prioridad:
//    1. Variables de entorno del Scheme de Xcode (IGDB_CLIENT_ID, IGDB_CLIENT_SECRET).
//    2. Info.plist (IGDBClientID, IGDBClientSecret), que se rellena desde
//       Config/Secrets.xcconfig — el equivalente a un .env en proyectos de Xcode.
//    3. Credenciales escritas a mano en el Inspector del Lab (solo para la sesión).
//
//  Si no hay credenciales, la app funciona con el catálogo local.
//

import Foundation

struct IGDBCredentials: Equatable, Sendable {
    var clientId: String
    var clientSecret: String
    /// Token ya emitido por Twitch. Si existe se usa directamente y no se pide uno nuevo.
    var manualAccessToken: String

    init(clientId: String = "", clientSecret: String = "", manualAccessToken: String = "") {
        self.clientId = clientId.trimmingCharacters(in: .whitespacesAndNewlines)
        self.clientSecret = clientSecret.trimmingCharacters(in: .whitespacesAndNewlines)
        self.manualAccessToken = manualAccessToken.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Hay lo necesario para hablar con IGDB (Client-ID + secreto o token).
    var isUsable: Bool {
        !clientId.isEmpty && (!clientSecret.isEmpty || !manualAccessToken.isEmpty)
    }
}

enum IGDBConfig {
    private static let clientIdKey = "IGDB_CLIENT_ID"
    private static let clientSecretKey = "IGDB_CLIENT_SECRET"

    /// Credenciales definidas en el entorno o en Info.plist.
    static var bundledCredentials: IGDBCredentials {
        IGDBCredentials(
            clientId: value(envKey: clientIdKey, plistKey: "IGDBClientID"),
            clientSecret: value(envKey: clientSecretKey, plistKey: "IGDBClientSecret")
        )
    }

    /// Combina lo configurado en el proyecto con lo escrito en el Inspector del Lab.
    /// Lo escrito a mano tiene prioridad.
    static func resolvedCredentials(manualClientId: String, manualToken: String) -> IGDBCredentials {
        let bundled = bundledCredentials
        let manualId = manualClientId.trimmingCharacters(in: .whitespacesAndNewlines)
        return IGDBCredentials(
            clientId: manualId.isEmpty ? bundled.clientId : manualId,
            clientSecret: bundled.clientSecret,
            manualAccessToken: manualToken
        )
    }

    private static func value(envKey: String, plistKey: String) -> String {
        if let env = ProcessInfo.processInfo.environment[envKey], isRealValue(env) {
            return env
        }
        if let plist = Bundle.main.object(forInfoDictionaryKey: plistKey) as? String, isRealValue(plist) {
            return plist
        }
        return ""
    }

    /// Descarta valores vacíos y variables de compilación sin resolver, p. ej. "$(IGDB_CLIENT_ID)".
    private static func isRealValue(_ raw: String) -> Bool {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !trimmed.hasPrefix("$(")
    }
}
