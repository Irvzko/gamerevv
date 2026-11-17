//
//  IGDBService.swift
//  GameRev
//
//  Cliente de la API v4 de IGDB (https://api.igdb.com/v4/games).
//
//  - Autenticación OAuth 2.0 (client credentials) contra Twitch, con token en caché
//    y renovación automática cuando caduca o IGDB responde 401.
//  - Consultas Apicalypse con reintentos y espera exponencial ante fallos de red,
//    límite de peticiones (429) y errores 5xx.
//  - Caché breve de respuestas para no repetir la misma búsqueda.
//  - Si IGDB no está disponible o no hay credenciales, responde con el catálogo local
//    e informa el motivo para que la interfaz pueda avisar sin bloquear al usuario.
//

import Foundation

// MARK: - Errores
enum IGDBServiceError: LocalizedError, Equatable {
    case connectionFailed
    case invalidResponse
    case unauthorized
    case rateLimited
    case serverError(status: Int)

    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "No fue posible conectar con el catálogo de IGDB. Comprueba tu conexión e inténtalo de nuevo."
        case .invalidResponse:
            return "La respuesta del servidor de IGDB no pudo procesarse."
        case .unauthorized:
            return "IGDB rechazó las credenciales. Revisa el Client-ID y el secreto de Twitch."
        case .rateLimited:
            return "IGDB recibió demasiadas consultas seguidas. Espera unos segundos."
        case .serverError(let status):
            return "IGDB respondió con un error (\(status)). Inténtalo más tarde."
        }
    }

    /// Texto corto para el aviso que acompaña al catálogo local.
    var shortNotice: String {
        switch self {
        case .connectionFailed: return "Sin conexión con IGDB"
        case .invalidResponse: return "Respuesta de IGDB no válida"
        case .unauthorized: return "Credenciales de IGDB rechazadas"
        case .rateLimited: return "Límite de consultas de IGDB alcanzado"
        case .serverError: return "IGDB no está disponible"
        }
    }
}

// MARK: - Resultado de una búsqueda
enum CatalogDataSource: Equatable {
    /// Solo catálogo incluido en la app.
    case local
    /// Catálogo local + resultados en vivo de IGDB.
    case igdb
}

struct CatalogSearchOutcome {
    let games: [Game]
    let source: CatalogDataSource
    /// IGDB falló, pero se entregó el catálogo local. `nil` si todo salió bien.
    let remoteIssue: IGDBServiceError?
}

// MARK: - Filtro local (función pura, fácil de probar)
enum CatalogFilter {
    static func apply(
        to games: [Game],
        query: String,
        genre: String?,
        platform: String?,
        year: Int?
    ) -> [Game] {
        let needle = normalize(query)

        return games.filter { game in
            if !needle.isEmpty {
                let haystack = [game.title, game.developerName, game.synopsis] + game.genres
                guard haystack.contains(where: { normalize($0).contains(needle) }) else { return false }
            }
            if let genre, !genre.isEmpty,
               !game.genres.contains(where: { $0.caseInsensitiveCompare(genre) == .orderedSame }) {
                return false
            }
            if let platform, !platform.isEmpty,
               !game.platforms.contains(where: { $0.caseInsensitiveCompare(platform) == .orderedSame }) {
                return false
            }
            if let year, game.releaseYear != year {
                return false
            }
            return true
        }
    }

    /// Ignora mayúsculas y acentos: "accion" encuentra "Acción".
    private static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}

// MARK: - DTOs
private struct TwitchTokenDTO: Decodable {
    let accessToken: String
    let expiresIn: Int
}

private struct IGDBGameDTO: Decodable {
    let id: Int
    let name: String
    let summary: String?
    let totalRating: Double?
    let totalRatingCount: Int?
    let aggregatedRating: Double?
    let firstReleaseDate: Int?
    let genres: [NamedDTO]?
    let platforms: [NamedDTO]?
    let gameModes: [NamedDTO]?
    let involvedCompanies: [InvolvedCompanyDTO]?
    let cover: ImageDTO?
    let artworks: [ImageDTO]?
    let screenshots: [ImageDTO]?

    struct NamedDTO: Decodable {
        let name: String
    }

    struct InvolvedCompanyDTO: Decodable {
        let company: NamedDTO?
        let developer: Bool?
        let publisher: Bool?
    }

    struct ImageDTO: Decodable {
        let imageId: String?
    }
}

// MARK: - Servicio
actor IGDBService {
    static let shared = IGDBService()

    private enum Constants {
        static let gamesEndpoint = URL(string: "https://api.igdb.com/v4/games")!
        static let tokenEndpoint = URL(string: "https://id.twitch.tv/oauth2/token")!
        static let imageBaseURL = "https://images.igdb.com/igdb/image/upload"
        static let pageSize = 20
        static let maxAttempts = 3
        static let responseCacheLifetime: TimeInterval = 300
        static let responseCacheLimit = 24
        static let gameFields = [
            "name", "summary", "total_rating", "total_rating_count", "aggregated_rating",
            "first_release_date", "genres.name", "platforms.name", "game_modes.name",
            "involved_companies.company.name", "involved_companies.developer",
            "involved_companies.publisher", "cover.image_id", "artworks.image_id",
            "screenshots.image_id"
        ].joined(separator: ",")
    }

    private struct CachedToken {
        let value: String
        let clientId: String
        let expiresAt: Date
    }

    private struct CachedResponse {
        let games: [Game]
        let storedAt: Date
    }

    private let session: URLSession
    private let decoder: JSONDecoder
    private var cachedToken: CachedToken?
    private var responseCache: [String: CachedResponse] = [:]

    init(session: URLSession = IGDBService.makeSession()) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 12
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }

    // MARK: API pública

    /// Busca en el catálogo local y, si hay credenciales, también en IGDB.
    /// Solo lanza error cuando ni siquiera el catálogo local puede responder
    /// (hoy, únicamente con el fallo simulado del Inspector del Lab).
    func searchCatalog(
        query: String,
        genre: String?,
        platform: String?,
        year: Int?,
        localCatalog: [Game],
        simulateFailure: Bool,
        credentials: IGDBCredentials
    ) async throws -> CatalogSearchOutcome {
        if simulateFailure {
            try await Task.sleep(nanoseconds: 400_000_000)
            throw IGDBServiceError.connectionFailed
        }

        var catalog = localCatalog
        var source = CatalogDataSource.local
        var remoteIssue: IGDBServiceError?

        if credentials.isUsable {
            do {
                let remoteGames = try await remoteGames(matching: query, credentials: credentials)
                catalog = Self.merge(local: localCatalog, remote: remoteGames)
                source = .igdb
            } catch is CancellationError {
                throw CancellationError()
            } catch let error as IGDBServiceError {
                remoteIssue = error
            } catch {
                remoteIssue = .connectionFailed
            }
        }

        try Task.checkCancellation()

        let filtered = CatalogFilter.apply(
            to: catalog,
            query: query,
            genre: genre,
            platform: platform,
            year: year
        )
        return CatalogSearchOutcome(games: filtered, source: source, remoteIssue: remoteIssue)
    }

    /// Olvida el token y las respuestas guardadas (p. ej. al cambiar credenciales).
    func resetSession() {
        cachedToken = nil
        responseCache.removeAll()
    }

    // MARK: Consulta remota

    private func remoteGames(matching query: String, credentials: IGDBCredentials) async throws -> [Game] {
        let cleanQuery = Self.sanitize(query)
        let cacheKey = "\(credentials.clientId)|\(cleanQuery.lowercased())"

        if let cached = responseCache[cacheKey],
           Date().timeIntervalSince(cached.storedAt) < Constants.responseCacheLifetime {
            return cached.games
        }

        let body = Self.apicalypseBody(for: cleanQuery)
        let data = try await performGamesRequest(body: body, credentials: credentials)

        let dtos: [IGDBGameDTO]
        do {
            dtos = try decoder.decode([IGDBGameDTO].self, from: data)
        } catch {
            throw IGDBServiceError.invalidResponse
        }

        let games = dtos.map(Self.makeGame(from:))
        storeInCache(games, for: cacheKey)
        return games
    }

    private func performGamesRequest(body: String, credentials: IGDBCredentials) async throws -> Data {
        do {
            let token = try await accessToken(for: credentials, forceRefresh: false)
            return try await send(gamesRequest(body: body, clientId: credentials.clientId, token: token))
        } catch IGDBServiceError.unauthorized where credentials.manualAccessToken.isEmpty {
            // El token guardado caducó o fue revocado: se pide uno nuevo una sola vez.
            let token = try await accessToken(for: credentials, forceRefresh: true)
            return try await send(gamesRequest(body: body, clientId: credentials.clientId, token: token))
        }
    }

    private func gamesRequest(body: String, clientId: String, token: String) -> URLRequest {
        var request = URLRequest(url: Constants.gamesEndpoint)
        request.httpMethod = "POST"
        request.setValue(clientId, forHTTPHeaderField: "Client-ID")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(body.utf8)
        return request
    }

    private func storeInCache(_ games: [Game], for key: String) {
        if responseCache.count >= Constants.responseCacheLimit,
           let oldest = responseCache.min(by: { $0.value.storedAt < $1.value.storedAt })?.key {
            responseCache.removeValue(forKey: oldest)
        }
        responseCache[key] = CachedResponse(games: games, storedAt: Date())
    }

    // MARK: OAuth 2.0 (Twitch · client credentials)

    private func accessToken(for credentials: IGDBCredentials, forceRefresh: Bool) async throws -> String {
        if !credentials.manualAccessToken.isEmpty {
            return credentials.manualAccessToken
        }

        if !forceRefresh,
           let cachedToken,
           cachedToken.clientId == credentials.clientId,
           cachedToken.expiresAt > Date().addingTimeInterval(60) {
            return cachedToken.value
        }

        guard !credentials.clientSecret.isEmpty else {
            throw IGDBServiceError.unauthorized
        }

        var form = URLComponents()
        form.queryItems = [
            URLQueryItem(name: "client_id", value: credentials.clientId),
            URLQueryItem(name: "client_secret", value: credentials.clientSecret),
            URLQueryItem(name: "grant_type", value: "client_credentials")
        ]

        var request = URLRequest(url: Constants.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data((form.percentEncodedQuery ?? "").utf8)

        let data = try await send(request)
        guard let dto = try? decoder.decode(TwitchTokenDTO.self, from: data) else {
            throw IGDBServiceError.invalidResponse
        }

        cachedToken = CachedToken(
            value: dto.accessToken,
            clientId: credentials.clientId,
            expiresAt: Date().addingTimeInterval(TimeInterval(dto.expiresIn))
        )
        return dto.accessToken
    }

    // MARK: Transporte con reintentos

    private func send(_ request: URLRequest) async throws -> Data {
        var attempt = 0

        while true {
            attempt += 1
            try Task.checkCancellation()
            let canRetry = attempt < Constants.maxAttempts

            do {
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    throw IGDBServiceError.invalidResponse
                }

                switch http.statusCode {
                case 200...299:
                    return data
                case 400, 401, 403:
                    // Twitch responde 400/403 con credenciales inválidas; IGDB, 401.
                    throw IGDBServiceError.unauthorized
                case 429:
                    guard canRetry else { throw IGDBServiceError.rateLimited }
                case 500...599:
                    guard canRetry else { throw IGDBServiceError.serverError(status: http.statusCode) }
                default:
                    throw IGDBServiceError.serverError(status: http.statusCode)
                }
            } catch let error as URLError {
                if error.code == .cancelled {
                    throw CancellationError()
                }
                guard canRetry, Self.isTransient(error) else {
                    throw IGDBServiceError.connectionFailed
                }
            }

            // Espera exponencial: 0.4 s, 0.8 s…
            let delay = 0.4 * pow(2.0, Double(attempt - 1))
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }

    private static func isTransient(_ error: URLError) -> Bool {
        switch error.code {
        case .timedOut, .networkConnectionLost, .cannotConnectToHost,
             .cannotFindHost, .dnsLookupFailed, .notConnectedToInternet:
            return true
        default:
            return false
        }
    }

    // MARK: Apicalypse

    /// Elimina caracteres que romperían la consulta Apicalypse.
    private static func sanitize(_ query: String) -> String {
        query
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: ";", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func apicalypseBody(for query: String) -> String {
        let fields = "fields \(Constants.gameFields);"
        let limit = "limit \(Constants.pageSize);"

        if query.isEmpty {
            // Sin texto: los juegos con más votos, sin ediciones alternativas.
            return "\(fields) where total_rating_count > 300 & version_parent = null & cover != null; sort total_rating_count desc; \(limit)"
        }
        return "search \"\(query)\"; \(fields) where version_parent = null; \(limit)"
    }

    // MARK: Mapeo DTO → Game

    private static func merge(local: [Game], remote: [Game]) -> [Game] {
        var merged = local
        for game in remote {
            let alreadyPresent = merged.contains { existing in
                if let lhs = existing.igdbId, let rhs = game.igdbId, lhs == rhs { return true }
                return existing.title.caseInsensitiveCompare(game.title) == .orderedSame
            }
            if !alreadyPresent {
                merged.append(game)
            }
        }
        return merged
    }

    private static func makeGame(from dto: IGDBGameDTO) -> Game {
        let releaseYear: Int
        if let timestamp = dto.firstReleaseDate {
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            releaseYear = Calendar(identifier: .gregorian).component(.year, from: date)
        } else {
            releaseYear = 0 // Sin fecha: la interfaz muestra "Por anunciar".
        }

        // IGDB puntúa de 0 a 100; GameRev, de 0 a 5. Sin votos se deja en 0 ("sin valorar").
        let rating = dto.totalRating.map { (($0 / 20.0) * 10).rounded() / 10 } ?? 0
        let metascore = dto.aggregatedRating.map { Int($0.rounded()) } ?? 0

        let companies = dto.involvedCompanies ?? []
        let developer = companies.first(where: { $0.developer == true })?.company?.name
            ?? companies.first?.company?.name
            ?? "Estudio no especificado"
        let publisher = companies.first(where: { $0.publisher == true })?.company?.name ?? developer

        let coverURL = (dto.cover?.imageId).map { imageURL(id: $0, size: "t_cover_big") } ?? ""
        let bannerId = dto.artworks?.first?.imageId ?? dto.screenshots?.first?.imageId
        let bannerURL = bannerId.map { imageURL(id: $0, size: "t_screenshot_big") } ?? ""

        let genres = uniqued((dto.genres ?? []).map { localizedGenre($0.name) })
        let platforms = uniqued((dto.platforms ?? []).map { normalizedPlatform($0.name) })
        let modes = uniqued((dto.gameModes ?? []).map { localizedGameMode($0.name) })

        let palette = ["#1E3A5F", "#312E81", "#134E4A", "#7C2D12", "#4C1D95", "#1F2937"]

        return Game(
            id: stableUUID(forIGDBId: dto.id),
            igdbId: dto.id,
            code: Game.makeCode(from: dto.name),
            title: dto.name,
            tagline: "",
            genres: genres.isEmpty ? ["Videojuego"] : genres,
            platforms: platforms,
            releaseYear: releaseYear,
            rating: rating,
            votesCount: dto.totalRatingCount ?? 0,
            metascore: metascore,
            gameMode: modes.isEmpty ? "No especificado" : modes.prefix(2).joined(separator: " · "),
            developerName: developer,
            publisherName: publisher,
            creatorProfileId: nil,
            credits: [],
            synopsis: dto.summary ?? "IGDB todavía no tiene una sinopsis para este título.",
            coverHex: palette[abs(dto.id) % palette.count],
            coverImageURL: coverURL,
            bannerImageURL: bannerURL,
            isFeatured: false
        )
    }

    /// Mismo juego de IGDB → mismo UUID en cada búsqueda. Así el diario y las reseñas
    /// siguen apuntando al juego correcto aunque se vuelva a consultar la API.
    private static func stableUUID(forIGDBId id: Int) -> UUID {
        let suffix = String(format: "%012d", abs(id) % 1_000_000_000_000)
        return UUID(uuidString: "16DB0000-0000-4000-8000-\(suffix)") ?? UUID()
    }

    private static func imageURL(id: String, size: String) -> String {
        "\(Constants.imageBaseURL)/\(size)/\(id).jpg"
    }

    private static func uniqued(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }

    private static func localizedGenre(_ name: String) -> String {
        let map: [String: String] = [
            "Role-playing (RPG)": "RPG",
            "Adventure": "Aventura",
            "Platform": "Plataformas",
            "Shooter": "Shooter",
            "Simulator": "Simulación",
            "Strategy": "Estrategia",
            "Turn-based strategy (TBS)": "Estrategia",
            "Real Time Strategy (RTS)": "Estrategia",
            "Tactical": "Táctico",
            "Puzzle": "Puzle",
            "Fighting": "Lucha",
            "Racing": "Carreras",
            "Sport": "Deportes",
            "Hack and slash/Beat 'em up": "Acción",
            "Point-and-click": "Aventura gráfica",
            "Visual Novel": "Novela visual",
            "Music": "Música",
            "Card & Board Game": "Cartas"
        ]
        return map[name] ?? name
    }

    private static func normalizedPlatform(_ name: String) -> String {
        if name.hasPrefix("PC") { return "PC" }
        if name.hasPrefix("PlayStation") { return "PlayStation" }
        if name.hasPrefix("Xbox") { return "Xbox" }
        if name.hasPrefix("Nintendo Switch") { return "Nintendo Switch" }
        if name == "Mac" || name == "macOS" { return "Mac" }
        return name
    }

    private static func localizedGameMode(_ name: String) -> String {
        let map: [String: String] = [
            "Single player": "1 jugador",
            "Multiplayer": "Multijugador",
            "Co-operative": "Cooperativo",
            "Split screen": "Pantalla dividida",
            "Massively Multiplayer Online (MMO)": "MMO"
        ]
        return map[name] ?? name
    }
}
