//
//  SeedData.swift
//  GameRev
//
//  Base de datos semilla estilo IMDb / IGDB con portadas oficiales, banners,
//  créditos de creadores y artistas, diario, categorías y reseñas.
//  La ampliación del catálogo (Dark Souls, Skyrim, Elden Ring…) vive en SeedCatalog.swift.
//

import Foundation

enum SeedData {
    // MARK: - IDs Fijos para Relaciones
    static let mauroId = UUID(uuidString: "11111111-1111-1111-1111-111111111101")!
    static let teamCherryId = UUID(uuidString: "11111111-1111-1111-1111-111111111102")!
    static let marinaId = UUID(uuidString: "11111111-1111-1111-1111-111111111103")!
    static let supergiantId = UUID(uuidString: "11111111-1111-1111-1111-111111111104")!
    static let maddyId = UUID(uuidString: "11111111-1111-1111-1111-111111111105")!
    static let sabotageId = UUID(uuidString: "11111111-1111-1111-1111-111111111106")!
    static let renatoId = UUID(uuidString: "11111111-1111-1111-1111-111111111107")!
    static let concernedApeId = UUID(uuidString: "11111111-1111-1111-1111-111111111108")!

    static let hollowKnightId = UUID(uuidString: "22222222-2222-2222-2222-222222222201")!
    static let hades2Id = UUID(uuidString: "22222222-2222-2222-2222-222222222202")!
    static let celesteId = UUID(uuidString: "22222222-2222-2222-2222-222222222203")!
    static let silksongId = UUID(uuidString: "22222222-2222-2222-2222-222222222204")!
    static let voidheartId = UUID(uuidString: "22222222-2222-2222-2222-222222222205")!
    static let seaOfStarsId = UUID(uuidString: "22222222-2222-2222-2222-222222222206")!
    static let stardewId = UUID(uuidString: "22222222-2222-2222-2222-222222222207")!
    static let discoElysiumId = UUID(uuidString: "22222222-2222-2222-2222-222222222208")!

    static let catIndiesId = UUID(uuidString: "33333333-3333-3333-3333-333333333301")!
    static let catRoguelikesId = UUID(uuidString: "33333333-3333-3333-3333-333333333302")!
    static let catObrasMaestrasId = UUID(uuidString: "33333333-3333-3333-3333-333333333303")!

    static let celesteReviewId = UUID(uuidString: "44444444-4444-4444-4444-444444444401")!
    static let hkReviewId = UUID(uuidString: "44444444-4444-4444-4444-444444444402")!
    static let hadesReviewId = UUID(uuidString: "44444444-4444-4444-4444-444444444403")!

    // MARK: - Perfiles Iniciales (Jugadores, Estudios y Artistas Independientes)
    static let initialProfiles: [UserProfile] = [
        UserProfile(
            id: mauroId,
            ownerId: mauroId,
            name: "Mauro Barcenas",
            username: "mauro.b",
            email: "mauro@gamerev.app",
            passwordHash: "123456",
            initials: "MB",
            bio: "Cazador de indies y mundos imposibles. Documentando cada aventura desde el primer nivel hasta los créditos finales.",
            profileType: .player,
            studioOrProject: "Moonlit Studio",
            creatorRole: "Artista conceptual",
            trajectory: "Diseño de entornos y personajes para videojuegos independientes 2D.",
            contactURL: "https://portfolio.example",
            portfolio: [
                PortfolioWork(
                    title: "Echoes of Hallownest (Concept Art)",
                    role: "Artista conceptual",
                    summary: "Exploración visual de entornos subterráneos y criaturas biomecánicas.",
                    year: "2026",
                    relatedGameId: hollowKnightId,
                    externalLink: "https://portfolio.example/echoes"
                )
            ]
        ),
        UserProfile(
            id: teamCherryId,
            ownerId: teamCherryId,
            name: "Team Cherry",
            username: "team.cherry",
            email: "contact@teamcherry.com.au",
            passwordHash: "123456",
            initials: "TC",
            bio: "Desarrolladores independientes con base en Adelaida, Australia. Creadores de mundos artesanales dibujados a mano.",
            profileType: .creator,
            studioOrProject: "Team Cherry",
            creatorRole: "Estudio Independiente",
            trajectory: "Fundado por Ari Gibson y William Pellen en 2014. Especializados en diseño de mundos interconectados, animación tradicional cuadro por cuadro y combate de precisión.",
            contactURL: "https://www.teamcherry.com.au",
            portfolio: [
                PortfolioWork(
                    title: "Hollow Knight",
                    role: "Dirección, Arte 2D y Diseño de Mundo",
                    summary: "Aventura de acción 2D clásica en el vasto reino interconectado de Hallownest con más de 150 enemigos dibujados a mano.",
                    year: "2017",
                    relatedGameId: hollowKnightId,
                    externalLink: "https://www.hollowknight.com"
                ),
                PortfolioWork(
                    title: "Hollow Knight: Silksong",
                    role: "Desarrollo Integral y Dirección Artística",
                    summary: "Secuela protagonizada por Hornet en un nuevo reino gobernado por la seda y el canto.",
                    year: "2025",
                    relatedGameId: silksongId,
                    externalLink: "https://hollowknightsilksong.com"
                ),
                PortfolioWork(
                    title: "Hollow Knight: Voidheart Edition",
                    role: "Expansiones y Diseño de Jefes",
                    summary: "Edición definitiva con las cuatro expansiones gratuitas: Hidden Dreams, The Grimm Troupe, Lifeblood y Godmaster.",
                    year: "2018",
                    relatedGameId: voidheartId
                )
            ]
        ),
        UserProfile(
            id: marinaId,
            ownerId: marinaId,
            name: "Marina Ríos",
            username: "marina.codes",
            email: "marina@gamerev.app",
            passwordHash: "123456",
            initials: "MR",
            bio: "Diseño personajes e ilustraciones para mundos fantásticos. Apasionada por el pixel art y la narrativa visual.",
            profileType: .creator,
            studioOrProject: "Estudio Río",
            creatorRole: "Ilustración y Concept Art",
            trajectory: "Más de 6 años colaborando con estudios independientes en dirección de arte, hojas de expresión de personajes, retratos de diálogo y key art promocional.",
            contactURL: "https://artstation.com",
            portfolio: [
                PortfolioWork(
                    title: "Celeste · retratos y arte conceptual invitado",
                    role: "Ilustradora de personajes",
                    summary: "Serie de retratos expresivos y láminas conmemorativas para capítulos de alta montaña.",
                    year: "2024",
                    relatedGameId: celesteId
                ),
                PortfolioWork(
                    title: "Sea of Stars · Ilustración de Solsticio",
                    role: "Artista de entornos e iluminación",
                    summary: "Composición de paletas dinámicas día/noche y escenarios costeros.",
                    year: "2025",
                    relatedGameId: seaOfStarsId
                )
            ]
        ),
        UserProfile(
            id: supergiantId,
            ownerId: supergiantId,
            name: "Supergiant Games",
            username: "supergiant",
            email: "contact@supergiantgames.com",
            passwordHash: "123456",
            initials: "SG",
            bio: "Estudio independiente de San Francisco reconocido por fusionar narrativa reactiva, dirección de arte pintada a mano y música inolvidable.",
            profileType: .creator,
            studioOrProject: "Supergiant Games",
            creatorRole: "Estudio de Desarrollo",
            trajectory: "Creadores galardonados de Bastion (2011), Transistor (2014), Pyre (2017), Hades (2020) y Hades II (2024).",
            contactURL: "https://www.supergiantgames.com",
            portfolio: [
                PortfolioWork(
                    title: "Hades II",
                    role: "Diseño de combate, narrativa mitológica y arte",
                    summary: "Secuela roguelike protagonizada por Melinoë en su lucha contra Cronos, el Titán del Tiempo.",
                    year: "2024",
                    relatedGameId: hades2Id
                )
            ]
        ),
        UserProfile(
            id: maddyId,
            ownerId: maddyId,
            name: "Maddy Makes Games",
            username: "maddymakesgames",
            email: "contact@maddymakesgames.com",
            passwordHash: "123456",
            initials: "MM",
            bio: "Colectivo independiente creador de Celeste y TowerFall.",
            profileType: .creator,
            studioOrProject: "Extremely OK Games / Maddy Makes Games",
            creatorRole: "Diseño de Niveles y Dirección",
            trajectory: "Pioneros en plataformas de precisión accesibles con narrativas íntimas sobre salud mental y superación.",
            contactURL: "https://exok.com",
            portfolio: [
                PortfolioWork(
                    title: "Celeste",
                    role: "Dirección, Diseño de Niveles y Guion",
                    summary: "Más de 700 pantallas de desafíos de plataformas milimétricos acompañados por la música de Lena Raine.",
                    year: "2018",
                    relatedGameId: celesteId
                )
            ]
        ),
        UserProfile(
            id: sabotageId,
            ownerId: sabotageId,
            name: "Sabotage Studio",
            username: "sabotage.studio",
            email: "info@sabotagestudio.com",
            passwordHash: "123456",
            initials: "SS",
            bio: "Estudio independiente de Quebec dedicado a modernizar los géneros clásicos retro.",
            profileType: .creator,
            studioOrProject: "Sabotage Studio",
            creatorRole: "Estudio RPG & Pixel Art",
            trajectory: "Ganadores de Best Independent Game en The Game Awards por Sea of Stars y creadores de The Messenger.",
            contactURL: "https://sabotagestudio.com",
            portfolio: [
                PortfolioWork(
                    title: "Sea of Stars",
                    role: "Desarrollo integral, Pixel Art e Iluminación Dinámica",
                    summary: "RPG por turnos con combate interactivo y banda sonora con participación de Yasunori Mitsuda.",
                    year: "2023",
                    relatedGameId: seaOfStarsId
                )
            ]
        ),
        UserProfile(
            id: concernedApeId,
            ownerId: concernedApeId,
            name: "Eric Barone (ConcernedApe)",
            username: "concernedape",
            email: "ape@stardewvalley.net",
            passwordHash: "123456",
            initials: "CA",
            bio: "Desarrollador solitario detrás de Stardew Valley y Haunted Chocolatier.",
            profileType: .creator,
            studioOrProject: "ConcernedApe LLC",
            creatorRole: "Desarrollador Solitario, Arte y Música",
            trajectory: "Programó, dibujó todos los sprites, compuso toda la música y escribió cada línea de diálogo de Stardew Valley de forma independiente.",
            contactURL: "https://www.stardewvalley.net",
            portfolio: [
                PortfolioWork(
                    title: "Stardew Valley",
                    role: "Programación, Pixel Art, Música y Diseño",
                    summary: "Simulador de vida rural y RPG abierto que transformó la escena indie mundial.",
                    year: "2016",
                    relatedGameId: stardewId
                )
            ]
        ),
        UserProfile(
            id: renatoId,
            ownerId: renatoId,
            name: "Renato Quintanilla",
            username: "renato.q",
            email: "renato@gamerev.app",
            passwordHash: "123456",
            initials: "RQ",
            bio: "Crítico de RPGs, amante de las bandas sonoras orquestales y coleccionista de ediciones físicas.",
            profileType: .player,
            studioOrProject: "",
            creatorRole: "",
            trajectory: "",
            contactURL: "",
            portfolio: []
        )
    ]

    // MARK: - Catálogo Inicial de Videojuegos (Estilo IMDb / IGDB con Portadas Oficiales)
    /// Catálogo completo: indies del Storyboard + ampliación (ver SeedCatalog.swift).
    static let initialGames: [Game] = storyboardGames + extendedGames

    static let storyboardGames: [Game] = [
        Game(
            id: hollowKnightId,
            igdbId: 14593,
            code: "HK",
            title: "Hollow Knight",
            tagline: "Forja tu propio camino en Hallownest, un reino vasto y olvidado.",
            genres: ["Acción", "Aventura", "Indie", "Metroidvania"],
            platforms: ["PC", "Nintendo Switch", "PlayStation", "Xbox"],
            releaseYear: 2017,
            rating: 4.8,
            votesCount: 14820,
            metascore: 90,
            gameMode: "1 jugador",
            developerName: "Team Cherry",
            publisherName: "Team Cherry",
            creatorProfileId: teamCherryId,
            credits: [
                GameCreatorCredit(profileId: teamCherryId, name: "Team Cherry", role: "Estudio Desarrollador"),
                GameCreatorCredit(profileId: marinaId, name: "Marina Ríos", role: "Arte Conceptual Invitado")
            ],
            synopsis: "Desciende a las profundidades de Hallownest, un antiguo reino de insectos en ruinas. Explora cavernas serpenteantes, ciudades antiguas y páramos mortales; combate contra criaturas corrompidas y descubre la historia oculta en el corazón del reino.",
            coverHex: "#1E3A5F",
            coverImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/367520/library_600x900_2x.jpg",
            bannerImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/367520/library_hero.jpg",
            isFeatured: true
        ),
        Game(
            id: hades2Id,
            igdbId: 228530,
            code: "HA",
            title: "Hades II",
            tagline: "Muerte a Cronos. Batalla más allá del Inframundo usando hechicería oscura.",
            genres: ["Acción", "Aventura", "Roguelike", "Indie"],
            platforms: ["PC", "Mac", "Nintendo Switch"],
            releaseYear: 2024,
            rating: 4.9,
            votesCount: 9640,
            metascore: 94,
            gameMode: "1 jugador",
            developerName: "Supergiant Games",
            publisherName: "Supergiant Games",
            creatorProfileId: supergiantId,
            credits: [
                GameCreatorCredit(profileId: supergiantId, name: "Supergiant Games", role: "Estudio Desarrollador")
            ],
            synopsis: "Como Melinoë, la inmortal Princesa del Inframundo, explorarás un mundo mitológico más grande y profundo, dominando armas de la noche y bendiciones de todo el Olimpo para derrotar a las fuerzas del Titán del Tiempo.",
            coverHex: "#1F2937",
            coverImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/1145350/library_600x900_2x.jpg",
            bannerImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/1145350/library_hero.jpg",
            isFeatured: false
        ),
        Game(
            id: celesteId,
            igdbId: 26226,
            code: "CE",
            title: "Celeste",
            tagline: "Respira. Tú puedes lograrlo.",
            genres: ["Aventura", "Plataformas", "Indie"],
            platforms: ["PC", "Nintendo Switch", "PlayStation", "Xbox"],
            releaseYear: 2018,
            rating: 4.9,
            votesCount: 18310,
            metascore: 92,
            gameMode: "1 jugador",
            developerName: "Maddy Makes Games",
            publisherName: "Extremely OK Games",
            creatorProfileId: maddyId,
            credits: [
                GameCreatorCredit(profileId: maddyId, name: "Maddy Makes Games", role: "Dirección y Diseño de Niveles"),
                GameCreatorCredit(profileId: marinaId, name: "Marina Ríos", role: "Ilustración de Personajes")
            ],
            synopsis: "Ayuda a Madeline a sobrevivir a sus demonios internos en su viaje hasta la cima de la montaña Celeste, en un juego de plataformas milimétrico y artesanal de los creadores del clásico TowerFall.",
            coverHex: "#1E293B",
            coverImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/504230/library_600x900_2x.jpg",
            bannerImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/504230/library_hero.jpg",
            isFeatured: false
        ),
        Game(
            id: silksongId,
            igdbId: 115289,
            code: "SI",
            title: "Hollow Knight: Silksong",
            tagline: "Asciende hasta la cima de un reino gobernado por la seda y el canto.",
            genres: ["Acción", "Aventura", "Indie", "Metroidvania"],
            platforms: ["PC", "Nintendo Switch", "PlayStation", "Xbox"],
            releaseYear: 2025,
            rating: 4.9,
            votesCount: 7420,
            metascore: 93,
            gameMode: "1 jugador",
            developerName: "Team Cherry",
            publisherName: "Team Cherry",
            creatorProfileId: teamCherryId,
            credits: [
                GameCreatorCredit(profileId: teamCherryId, name: "Team Cherry", role: "Estudio Desarrollador")
            ],
            synopsis: "Juega como Hornet, princesa protectora de Hallownest, y aventúrate a través de un nuevo reino desconocido. Capturada y llevada a esta tierra extraña, Hornet debe luchar contra enemigos y resolver misterios mientras asciende en un peregrinaje mortal.",
            coverHex: "#312E81",
            coverImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/1030300/library_600x900_2x.jpg",
            bannerImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/1030300/library_hero.jpg",
            isFeatured: false
        ),
        Game(
            id: seaOfStarsId,
            igdbId: 133236,
            code: "SE",
            title: "Sea of Stars",
            tagline: "Dos Hijos del Solsticio unirán el poder del sol y la luna.",
            genres: ["RPG", "Aventura", "Indie"],
            platforms: ["PC", "Nintendo Switch", "PlayStation", "Xbox"],
            releaseYear: 2023,
            rating: 4.6,
            votesCount: 6150,
            metascore: 87,
            gameMode: "1 jugador",
            developerName: "Sabotage Studio",
            publisherName: "Sabotage Studio",
            creatorProfileId: sabotageId,
            credits: [
                GameCreatorCredit(profileId: sabotageId, name: "Sabotage Studio", role: "Estudio Desarrollador"),
                GameCreatorCredit(profileId: marinaId, name: "Marina Ríos", role: "Ilustración de Solsticio")
            ],
            synopsis: "Un RPG por turnos inspirado en los clásicos de los años 90. Cuenta la historia de dos Hijos del Solsticio que combinarán los poderes del sol y la luna para realizar Magia de Eclipse, la única fuerza capaz de derrotar a las creaciones del alquimista conocido como El Fleshmancer.",
            coverHex: "#1D4ED8",
            coverImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/1244090/library_600x900_2x.jpg",
            bannerImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/1244090/library_hero.jpg",
            isFeatured: false
        ),
        Game(
            id: stardewId,
            igdbId: 17000,
            code: "SV",
            title: "Stardew Valley",
            tagline: "Construye la granja de tus sueños y devuelve la vida al valle.",
            genres: ["RPG", "Simulación", "Indie"],
            platforms: ["PC", "Mac", "Nintendo Switch", "PlayStation", "Xbox", "iOS"],
            releaseYear: 2016,
            rating: 4.9,
            votesCount: 24500,
            metascore: 89,
            gameMode: "1-4 jugadores",
            developerName: "ConcernedApe",
            publisherName: "ConcernedApe",
            creatorProfileId: concernedApeId,
            credits: [
                GameCreatorCredit(profileId: concernedApeId, name: "Eric Barone (ConcernedApe)", role: "Creador Solitario (Código, Arte y Música)")
            ],
            synopsis: "Has heredado la antigua parcela agrícola de tu abuelo en Stardew Valley. Equipado con herramientas de segunda mano y unas pocas monedas, te dispones a comenzar tu nueva vida.",
            coverHex: "#15803D",
            coverImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/413150/library_600x900_2x.jpg",
            bannerImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/413150/library_hero.jpg",
            isFeatured: false
        ),
        Game(
            id: voidheartId,
            igdbId: 109462,
            code: "HO",
            title: "Hollow Knight: Voidheart",
            tagline: "La edición definitiva del viaje por las profundidades de Hallownest.",
            genres: ["Acción", "Aventura", "Indie", "Metroidvania"],
            platforms: ["Nintendo Switch", "PlayStation", "Xbox"],
            releaseYear: 2018,
            rating: 4.8,
            votesCount: 5390,
            metascore: 91,
            gameMode: "1 jugador",
            developerName: "Team Cherry",
            publisherName: "Team Cherry",
            creatorProfileId: teamCherryId,
            credits: [
                GameCreatorCredit(profileId: teamCherryId, name: "Team Cherry", role: "Estudio Desarrollador")
            ],
            synopsis: "Edición expandida que reúne la aventura original en Hallownest junto con los cuatro paquetes de contenido adicional: Hidden Dreams, The Grimm Troupe, Lifeblood y Godmaster.",
            coverHex: "#0F172A",
            coverImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/367520/header.jpg",
            bannerImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/367520/library_hero.jpg",
            isFeatured: false
        ),
        Game(
            id: discoElysiumId,
            igdbId: 26472,
            code: "DE",
            title: "Disco Elysium: The Final Cut",
            tagline: "¿Qué clase de detective eres?",
            genres: ["RPG", "Aventura", "Indie"],
            platforms: ["PC", "Mac", "Nintendo Switch", "PlayStation", "Xbox"],
            releaseYear: 2019,
            rating: 4.8,
            votesCount: 11200,
            metascore: 97,
            gameMode: "1 jugador",
            developerName: "ZA/UM",
            publisherName: "ZA/UM",
            creatorProfileId: marinaId,
            credits: [
                GameCreatorCredit(profileId: marinaId, name: "Marina Ríos", role: "Análisis de Dirección de Arte")
            ],
            synopsis: "Un revolucionario juego de rol de mundo abierto. Eres un detective con un sistema único de habilidades a tu disposición y una ciudad entera que recorrer.",
            coverHex: "#7C2D12",
            coverImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/632470/library_600x900_2x.jpg",
            bannerImageURL: "https://cdn.cloudflare.steamstatic.com/steam/apps/632470/library_hero.jpg",
            isFeatured: false
        )
    ]

    // MARK: - Categorías Personalizadas Iniciales
    static let initialCategories: [GameCategory] = [
        GameCategory(id: catIndiesId, ownerId: mauroId, name: "Indies favoritos", colorHex: "#F5C518"),
        GameCategory(id: catRoguelikesId, ownerId: mauroId, name: "Roguelikes", colorHex: "#8B5CF6"),
        GameCategory(id: catObrasMaestrasId, ownerId: mauroId, name: "Obras Maestras 10/10", colorHex: "#10B981")
    ]

    // MARK: - Entradas Iniciales del Diario
    static let initialDiaryEntries: [DiaryEntry] = [
        DiaryEntry(
            userId: mauroId,
            gameId: hollowKnightId,
            status: .playing,
            categoryId: catIndiesId,
            personalNote: "Explorando Ciudad de Lágrimas y el Coliseo de los Insensatos. El diseño de sonido y mapa no tiene igual.",
            personalRating: 5,
            hoursPlayed: 42
        ),
        DiaryEntry(
            userId: mauroId,
            gameId: hades2Id,
            status: .playing,
            categoryId: catRoguelikesId,
            personalNote: "Dominando los encantamientos nocturnos con las espadas hermanas. Cada intento revela nuevo diálogo.",
            personalRating: 5,
            hoursPlayed: 28
        ),
        DiaryEntry(
            userId: mauroId,
            gameId: seaOfStarsId,
            status: .playing,
            categoryId: catIndiesId,
            personalNote: "El sistema de combate por turnos cronometrado y la iluminación dinámica son brillantes.",
            personalRating: 4,
            hoursPlayed: 19
        ),
        DiaryEntry(
            userId: mauroId,
            gameId: celesteId,
            status: .completed,
            categoryId: catObrasMaestrasId,
            personalNote: "Completadas todas las caras B y el Capítulo 9 (Farewell). Una obra maestra absoluta.",
            personalRating: 5,
            hoursPlayed: 35
        ),
        DiaryEntry(
            userId: marinaId,
            gameId: celesteId,
            status: .completed,
            categoryId: nil,
            personalNote: "Referente absoluto en dirección de arte, animación expresiva y narrativa emocional.",
            personalRating: 5,
            hoursPlayed: 30
        ),
        DiaryEntry(
            userId: marinaId,
            gameId: hollowKnightId,
            status: .replaying,
            categoryId: nil,
            personalNote: "Estudiando la composición de fondos multicapa de Ari Gibson.",
            personalRating: 5,
            hoursPlayed: 65
        ),
        DiaryEntry(
            userId: renatoId,
            gameId: stardewId,
            status: .completed,
            categoryId: nil,
            personalNote: "Increíble que una sola persona haya creado todo el arte, música y programación.",
            personalRating: 5,
            hoursPlayed: 110
        )
    ]

    // MARK: - Mini-reseñas Iniciales
    static let initialReviews: [Review] = extendedReviews + storyboardReviews

    static let storyboardReviews: [Review] = [
        Review(
            id: celesteReviewId,
            gameId: celesteId,
            authorId: marinaId,
            authorUsername: "marina.codes",
            authorName: "Marina Ríos",
            rating: 4.9,
            title: "Una experiencia precisa y emotiva donde cada pantalla cuenta una historia",
            text: "Una experiencia precisa y emotiva. Cada nivel cuenta algo y la manera en que las mecánicas de escalada reflejan el estado emocional de Madeline es ejemplar.",
            likesCount: 24,
            createdAt: daysAgo(7)
        ),
        Review(
            id: hkReviewId,
            gameId: hollowKnightId,
            authorId: marinaId,
            authorUsername: "marina.codes",
            authorName: "Marina Ríos",
            rating: 4.8,
            title: "Un mundo artesanal inolvidable",
            text: "Un mundo inolvidable. Preciso e inolvidable. El trabajo de Team Cherry demuestra que un equipo pequeño puede construir uno de los universos más atmosféricos de la historia.",
            likesCount: 19,
            createdAt: daysAgo(9)
        ),
        Review(
            id: hadesReviewId,
            gameId: hades2Id,
            authorId: renatoId,
            authorUsername: "renato.q",
            authorName: "Renato Quintanilla",
            rating: 5.0,
            title: "Supergiant vuelve a superar el estándar del género roguelike",
            text: "El sistema de Magick y los ataques Omega transforman por completo el ritmo del combate frente al primer juego. La dirección de arte de Jen Zee brilla en cada retrato.",
            likesCount: 15,
            createdAt: daysAgo(2.5)
        )
    ]

    // MARK: - Comentarios Iniciales
    static let initialComments: [ReviewComment] = storyboardComments + extendedComments

    static let storyboardComments: [ReviewComment] = [
        ReviewComment(
            reviewId: celesteReviewId,
            authorId: mauroId,
            authorUsername: "mauro.b",
            authorName: "Mauro Barcenas",
            text: "La música de Lena Raine también es increíble, especialmente en el capítulo del espejo.",
            createdAt: daysAgo(6.2)
        ),
        ReviewComment(
            reviewId: celesteReviewId,
            authorId: renatoId,
            authorUsername: "renato.q",
            authorName: "Renato Quintanilla",
            text: "Totalmente de acuerdo, las caras B ponen a prueba toda la memoria muscular sin sentirse injustas.",
            createdAt: daysAgo(5.9)
        ),
        ReviewComment(
            reviewId: hkReviewId,
            authorId: mauroId,
            authorUsername: "mauro.b",
            authorName: "Mauro Barcenas",
            text: "Llegar por primera vez a Ciudad de Lágrimas con la lluvia cayendo es un momento inolvidable.",
            createdAt: daysAgo(5.6)
        )
    ]
}
