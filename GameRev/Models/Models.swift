//
//  Models.swift
//  GameRev
//
//  Lab iOS Ago-Dic 2026 · Equipo 6
//  Integrantes:
//  - Mauro Ernesto Medrano Barcenas (FIME)
//  - Irving Tadeo Saldaña Gaytan (FIME)
//  - Angel David Gomez Dominguez (FCFM)
//  - Renato Quintanilla Solis (FCFM)
//  Profesor: Azael Flores
//

import Foundation

// MARK: - Tipo de Perfil (Jugador o Creador)
enum ProfileType: String, Codable, CaseIterable, Identifiable {
    case player = "Jugador"
    case creator = "Creador"

    var id: String { rawValue }

    var badgeTitle: String {
        switch self {
        case .player: return "JUGADOR"
        case .creator: return "CREADOR"
        }
    }
}

// MARK: - Trabajo del Portafolio (Creadores)
struct PortfolioWork: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var title: String
    var role: String
    var summary: String
    var year: String
    var relatedGameId: UUID?
    var externalLink: String = ""
}

// MARK: - Perfil de Usuario / Creador
struct UserProfile: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var ownerId: UUID // Regla de permiso: currentUser.id == profile.ownerId
    var name: String
    var username: String
    var email: String
    var passwordHash: String
    var initials: String
    var bio: String
    var profileType: ProfileType

    // Campos adicionales para perfiles de Creador (Diagramas 06 y 07)
    var studioOrProject: String
    var creatorRole: String
    var trajectory: String
    var contactURL: String
    var portfolio: [PortfolioWork]

    var isCreator: Bool {
        profileType == .creator
    }

    var roleBadgeText: String {
        if isCreator {
            let roleUpper = creatorRole.isEmpty ? "ESTUDIO" : creatorRole.uppercased()
            return "CREADOR · \(roleUpper)"
        } else {
            return "JUGADOR"
        }
    }
}

// MARK: - Crédito de Talento en un Videojuego (Estilo IMDb Cast & Crew)
struct GameCreatorCredit: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var profileId: UUID
    var name: String
    var role: String
}

// MARK: - Videojuego (Catálogo Global / IGDB estilo IMDb)
struct Game: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var igdbId: Int?
    var code: String
    var title: String
    var tagline: String
    var genres: [String]
    var platforms: [String]
    var releaseYear: Int
    var rating: Double // Sobre 5.0
    var votesCount: Int
    var metascore: Int
    var gameMode: String
    var developerName: String
    var publisherName: String
    var creatorProfileId: UUID?
    var credits: [GameCreatorCredit]
    var synopsis: String
    var coverHex: String
    var coverImageURL: String
    var bannerImageURL: String
    var isFeatured: Bool

    var genresFormatted: String {
        genres.joined(separator: " · ")
    }

    var platformsFormatted: String {
        platforms.joined(separator: ", ")
    }

    var primaryGenreAndYear: String {
        let firstGenre = genres.first ?? "Videojuego"
        return "\(firstGenre) · \(releaseYearText)"
    }

    // MARK: Presentación segura de datos incompletos (p. ej. juegos recién llegados de IGDB)

    /// Año de lanzamiento o "Por anunciar" si IGDB no tiene fecha.
    var releaseYearText: String {
        releaseYear > 0 ? String(releaseYear) : "Por anunciar"
    }

    var hasRating: Bool { rating > 0 }

    /// "4.8" o "—" cuando el juego todavía no tiene votos.
    var ratingText: String {
        hasRating ? String(format: "%.1f", rating) : "—"
    }

    var hasMetascore: Bool { metascore > 0 }

    /// "14,8 k votos", "320 votos" o "Sin votos".
    var votesText: String {
        switch votesCount {
        case ..<1:
            return "Sin votos"
        case ..<1000:
            return "\(votesCount) votos"
        default:
            return String(format: "%.1f k votos", Double(votesCount) / 1000.0)
        }
    }

    /// Portada ligera para listas y carruseles. Las portadas "_2x" de Steam miden
    /// 1200×1800 px (≈8 MB ya decodificadas); en miniaturas se usa la versión 600×900.
    var thumbnailImageURL: String {
        coverImageURL.replacingOccurrences(of: "library_600x900_2x.jpg", with: "library_600x900.jpg")
    }

    /// Banner ligero (616×353) para Inicio. El "library_hero" de Steam mide 3840×1240 px
    /// y solo se usa en la ficha del juego, donde hay una única imagen grande a la vez.
    var lightBannerImageURL: String {
        bannerImageURL.replacingOccurrences(of: "library_hero.jpg", with: "capsule_616x353.jpg")
    }

    /// Iniciales para la portada de respaldo: "Dark Souls" → "DS", "Celeste" → "CE".
    static func makeCode(from title: String) -> String {
        let words = title.split(separator: " ").filter { $0.first?.isLetter == true || $0.first?.isNumber == true }
        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
        return String(title.prefix(2)).uppercased()
    }
}

// MARK: - Estados del Diario (Diagrama 04)
enum DiaryStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pendiente"
    case playing = "Jugando"
    case completed = "Completado"
    case dropped = "Abandonado"
    case replaying = "Rejugando"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .pending: return "clock.fill"
        case .playing: return "gamecontroller.fill"
        case .completed: return "checkmark.seal.fill"
        case .dropped: return "xmark.circle.fill"
        case .replaying: return "arrow.clockwise.circle.fill"
        }
    }
}

// MARK: - Categoría Personalizada (Diagrama 04)
struct GameCategory: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var ownerId: UUID
    var name: String
    var colorHex: String = "#F5C518"
}

// MARK: - Entrada del Diario Personal (Diagrama 04)
struct DiaryEntry: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var userId: UUID
    var gameId: UUID
    var status: DiaryStatus
    var categoryId: UUID?
    var personalNote: String
    var personalRating: Int? // 1 a 5 estrellas
    var hoursPlayed: Int = 0
    var updatedAt: Date = Date()
}

// MARK: - Comentario en una Reseña (Diagrama 05)
struct ReviewComment: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var reviewId: UUID
    var authorId: UUID
    var authorUsername: String
    var authorName: String
    var text: String
    var createdAt: Date = Date()
}

// MARK: - Mini-reseña de un Videojuego (Diagrama 05)
struct Review: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var gameId: UUID
    var authorId: UUID
    var authorUsername: String
    var authorName: String
    var rating: Double
    var title: String
    var text: String
    var containsSpoilers: Bool = false
    var likesCount: Int = 0
    var createdAt: Date = Date()
}

// MARK: - Orden de las Reseñas (Escena 8)
enum ReviewSortOption: String, CaseIterable, Identifiable {
    case recent = "Más recientes"
    case topRated = "Mejor valoradas"
    case mostLiked = "Más útiles"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .recent: return "clock"
        case .topRated: return "star"
        case .mostLiked: return "hand.thumbsup"
        }
    }
}

// MARK: - Acción Pendiente Protegida (Diagrama 02)
enum PendingAction: Equatable {
    case saveToDiary(Game)
    case openDiary
    case writeReview(Game?)
    case writeComment(Review)
    case openMyProfile
    case editMyProfile

    var descriptionText: String {
        switch self {
        case .saveToDiary(let game):
            return "Guardar \(game.title) en mi diario"
        case .openDiary:
            return "Abrir mi diario personal"
        case .writeReview(let game):
            if let game {
                return "Escribir reseña de \(game.title)"
            }
            return "Escribir una mini-reseña"
        case .writeComment(let review):
            return "Comentar en reseña de @\(review.authorUsername)"
        case .openMyProfile:
            return "Consultar mi perfil"
        case .editMyProfile:
            return "Editar mi perfil y portafolio"
        }
    }

    var promptSubtitle: String {
        switch self {
        case .saveToDiary:
            return "Inicia sesión o crea una cuenta para registrar este título en tu diario personal."
        case .openDiary:
            return "Inicia sesión para consultar y organizar tu diario por estados y categorías."
        case .writeReview:
            return "Inicia sesión para publicar tu mini-reseña y calificación en GameRev."
        case .writeComment:
            return "Inicia sesión para participar en el debate de esta reseña."
        case .openMyProfile, .editMyProfile:
            return "Inicia sesión para administrar tu perfil y tu portafolio de creador."
        }
    }
}

// MARK: - Estados de Error Recuperables (Resiliencia)
enum RecoverableErrorType: String, Identifiable, CaseIterable {
    case connectionError = "CONNECTION_ERROR"
    case emptyResults = "EMPTY_RESULTS"
    case authError = "AUTH_ERROR"
    case invalidForm = "INVALID_FORM"
    case unauthorized = "UNAUTHORIZED"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .connectionError:
            return "No fue posible conectar con el catálogo de IGDB."
        case .emptyResults:
            return "No encontramos coincidencias."
        case .authError:
            return "Correo o contraseña incorrectos."
        case .invalidForm:
            return "Revisa los campos indicados."
        case .unauthorized:
            return "No tienes permiso para modificar este perfil."
        }
    }

    var message: String {
        switch self {
        case .connectionError:
            return "Comprueba tu conexión a internet e inténtalo de nuevo."
        case .emptyResults:
            return "Ajusta los filtros de género, plataforma o año, o prueba otro término."
        case .authError:
            return "Verifica tus credenciales o regístrate si aún no tienes cuenta."
        case .invalidForm:
            return "Completa los campos obligatorios con datos válidos antes de guardar."
        case .unauthorized:
            return "Solo el propietario de la cuenta activa puede editar su perfil o portafolio."
        }
    }

    var buttonTitle: String {
        switch self {
        case .connectionError:
            return "Reintentar conexión"
        case .emptyResults:
            return "Limpiar filtros"
        case .authError:
            return "Revisar credenciales"
        case .invalidForm:
            return "Corregir campos"
        case .unauthorized:
            return "Volver al perfil"
        }
    }
}

// MARK: - Pestañas Principales
enum MainTab: String, CaseIterable, Identifiable {
    case home = "Inicio"
    case catalog = "Catálogo"
    case diary = "Mi Diario"
    case reviews = "Reseñas"
    case profile = "Perfiles"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .home: return "film.stack"
        case .catalog: return "magnifyingglass"
        case .diary: return "bookmark.square"
        case .reviews: return "star.bubble"
        case .profile: return "person.2"
        }
    }
}
