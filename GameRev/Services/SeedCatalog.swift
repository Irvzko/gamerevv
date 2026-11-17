//
//  SeedCatalog.swift
//  GameRev
//
//  Ampliación del catálogo semilla con títulos de gran presupuesto y clásicos
//  (Dark Souls, Skyrim, Elden Ring, The Witcher 3…) y sus reseñas de comunidad.
//  Mantiene el catálogo en 24 juegos: suficiente variedad sin cargar de más
//  la memoria del simulador. Las pantallas muestran el catálogo por tramos del 30 %.
//
//  Las valoraciones y los votos son datos de demostración de la comunidad GameRev.
//

import Foundation

extension SeedData {
    // MARK: - IDs Fijos
    static let darkSoulsId = UUID(uuidString: "22222222-2222-2222-2222-222222222209")!
    static let darkSouls3Id = UUID(uuidString: "22222222-2222-2222-2222-222222222210")!
    static let eldenRingId = UUID(uuidString: "22222222-2222-2222-2222-222222222211")!
    static let sekiroId = UUID(uuidString: "22222222-2222-2222-2222-222222222212")!
    static let skyrimId = UUID(uuidString: "22222222-2222-2222-2222-222222222213")!
    static let witcher3Id = UUID(uuidString: "22222222-2222-2222-2222-222222222214")!
    static let baldursGate3Id = UUID(uuidString: "22222222-2222-2222-2222-222222222215")!
    static let cyberpunkId = UUID(uuidString: "22222222-2222-2222-2222-222222222216")!
    static let redDead2Id = UUID(uuidString: "22222222-2222-2222-2222-222222222217")!
    static let hadesId = UUID(uuidString: "22222222-2222-2222-2222-222222222218")!
    static let cupheadId = UUID(uuidString: "22222222-2222-2222-2222-222222222219")!
    static let deadCellsId = UUID(uuidString: "22222222-2222-2222-2222-222222222220")!
    static let portal2Id = UUID(uuidString: "22222222-2222-2222-2222-222222222221")!
    static let undertaleId = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    static let outerWildsId = UUID(uuidString: "22222222-2222-2222-2222-222222222223")!
    static let godOfWarId = UUID(uuidString: "22222222-2222-2222-2222-222222222224")!

    static let darkSoulsReviewId = UUID(uuidString: "44444444-4444-4444-4444-444444444404")!
    static let skyrimReviewId = UUID(uuidString: "44444444-4444-4444-4444-444444444405")!
    static let eldenRingReviewId = UUID(uuidString: "44444444-4444-4444-4444-444444444406")!
    static let witcherReviewId = UUID(uuidString: "44444444-4444-4444-4444-444444444407")!

    /// Fecha relativa para que las reseñas semilla tengan un orden cronológico estable.
    static func daysAgo(_ days: Double) -> Date {
        Date().addingTimeInterval(-days * 86_400)
    }

    // MARK: - Fábrica de juegos con arte de la biblioteca de Steam
    private static func steamGame(
        id: UUID,
        igdbId: Int? = nil,
        steamAppId: Int,
        title: String,
        tagline: String,
        genres: [String],
        platforms: [String],
        year: Int,
        rating: Double,
        votes: Int,
        metascore: Int,
        mode: String = "1 jugador",
        developer: String,
        publisher: String,
        synopsis: String,
        coverHex: String
    ) -> Game {
        let base = "https://cdn.cloudflare.steamstatic.com/steam/apps/\(steamAppId)"
        return Game(
            id: id,
            igdbId: igdbId,
            code: Game.makeCode(from: title),
            title: title,
            tagline: tagline,
            genres: genres,
            platforms: platforms,
            releaseYear: year,
            rating: rating,
            votesCount: votes,
            metascore: metascore,
            gameMode: mode,
            developerName: developer,
            publisherName: publisher,
            creatorProfileId: nil,
            credits: [],
            synopsis: synopsis,
            coverHex: coverHex,
            coverImageURL: "\(base)/library_600x900_2x.jpg",
            bannerImageURL: "\(base)/library_hero.jpg",
            isFeatured: false
        )
    }

    // MARK: - Catálogo Ampliado
    static let extendedGames: [Game] = [
        steamGame(
            id: darkSoulsId,
            steamAppId: 570940,
            title: "Dark Souls: Remastered",
            tagline: "Prepárate para morir. Otra vez.",
            genres: ["Acción", "RPG", "Souls-like"],
            platforms: ["PC", "Nintendo Switch", "PlayStation", "Xbox"],
            year: 2018,
            rating: 4.7,
            votes: 21300,
            metascore: 84,
            mode: "1 jugador · Cooperativo en línea",
            developer: "FromSoftware",
            publisher: "Bandai Namco",
            synopsis: "Regresa a Lordran, un reino interconectado donde cada atajo descubierto se siente como una victoria. El juego que definió un género: combate metódico, hogueras como único refugio y una historia que se cuenta a través de sus ruinas.",
            coverHex: "#3F3A2E"
        ),
        steamGame(
            id: darkSouls3Id,
            igdbId: 11133,
            steamAppId: 374320,
            title: "Dark Souls III",
            tagline: "El fuego se apaga. Los Señores abandonan sus tronos.",
            genres: ["Acción", "RPG", "Souls-like"],
            platforms: ["PC", "PlayStation", "Xbox"],
            year: 2016,
            rating: 4.7,
            votes: 19800,
            metascore: 89,
            mode: "1 jugador · Cooperativo en línea",
            developer: "FromSoftware",
            publisher: "Bandai Namco",
            synopsis: "En el reino de Lothric, la Primera Llama está a punto de extinguirse. Como Latente, deberás devolver a los Señores de la Ceniza a sus tronos en el capítulo más ágil y con los jefes más espectaculares de la trilogía.",
            coverHex: "#4A1D12"
        ),
        steamGame(
            id: eldenRingId,
            igdbId: 119133,
            steamAppId: 1245620,
            title: "Elden Ring",
            tagline: "Álzate, Sinluz, y conviértete en Señor del Círculo.",
            genres: ["Acción", "RPG", "Mundo abierto", "Souls-like"],
            platforms: ["PC", "PlayStation", "Xbox"],
            year: 2022,
            rating: 4.9,
            votes: 31200,
            metascore: 96,
            mode: "1 jugador · Cooperativo en línea",
            developer: "FromSoftware",
            publisher: "Bandai Namco",
            synopsis: "Las Tierras Intermedias te esperan: un mundo abierto sin marcadores que te lleven de la mano, con mazmorras ocultas tras cada colina y una mitología creada junto a George R. R. Martin. Explora a caballo, enfréntate a semidioses y forja tu propio camino.",
            coverHex: "#5B4A1E"
        ),
        steamGame(
            id: sekiroId,
            steamAppId: 814380,
            title: "Sekiro: Shadows Die Twice",
            tagline: "Véngate. Recupera tu honor. Mata con ingenio.",
            genres: ["Acción", "Aventura", "Souls-like"],
            platforms: ["PC", "PlayStation", "Xbox"],
            year: 2019,
            rating: 4.7,
            votes: 15400,
            metascore: 90,
            developer: "FromSoftware",
            publisher: "Activision",
            synopsis: "Eres el Lobo manco, un shinobi desfigurado que debe rescatar a su joven señor en el Japón de la era Sengoku. Aquí no hay escudo tras el que esconderse: el combate es un duelo de desvíos donde romper la postura del rival lo es todo.",
            coverHex: "#7F1D1D"
        ),
        steamGame(
            id: skyrimId,
            igdbId: 472,
            steamAppId: 489830,
            title: "The Elder Scrolls V: Skyrim",
            tagline: "Los dragones han vuelto. Solo el Sangre de Dragón puede detenerlos.",
            genres: ["RPG", "Aventura", "Mundo abierto"],
            platforms: ["PC", "Nintendo Switch", "PlayStation", "Xbox"],
            year: 2011,
            rating: 4.8,
            votes: 42600,
            metascore: 94,
            developer: "Bethesda Game Studios",
            publisher: "Bethesda Softworks",
            synopsis: "Escapa de tu ejecución y descubre que eres Dovahkiin, capaz de absorber el alma de los dragones. Una provincia nevada entera para recorrer a tu ritmo: gremios, guerras civiles, ruinas dwemer y cientos de historias que empiezan al desviarte del camino.",
            coverHex: "#334155"
        ),
        steamGame(
            id: witcher3Id,
            igdbId: 1942,
            steamAppId: 292030,
            title: "The Witcher 3: Wild Hunt",
            tagline: "Encuentra a la niña de la profecía antes que la Cacería Salvaje.",
            genres: ["RPG", "Aventura", "Mundo abierto"],
            platforms: ["PC", "Nintendo Switch", "PlayStation", "Xbox"],
            year: 2015,
            rating: 4.9,
            votes: 38900,
            metascore: 93,
            developer: "CD Projekt Red",
            publisher: "CD Projekt",
            synopsis: "Geralt de Rivia, cazador de monstruos a sueldo, sigue el rastro de Ciri por un continente devastado por la guerra. Sus misiones secundarias están escritas con el mismo cuidado que la trama principal, y casi ninguna decisión es del todo buena o mala.",
            coverHex: "#3B1F1F"
        ),
        steamGame(
            id: baldursGate3Id,
            igdbId: 119171,
            steamAppId: 1086940,
            title: "Baldur's Gate 3",
            tagline: "Reúne a tu grupo y regresa a los Reinos Olvidados.",
            genres: ["RPG", "Estrategia", "Aventura"],
            platforms: ["PC", "Mac", "PlayStation", "Xbox"],
            year: 2023,
            rating: 4.9,
            votes: 27500,
            metascore: 96,
            mode: "1-4 jugadores",
            developer: "Larian Studios",
            publisher: "Larian Studios",
            synopsis: "Un parásito azotamentes crece en tu cabeza y el tiempo corre. Basado en Dungeons & Dragons, cada conversación, tirada de dado y combate por turnos puede resolverse de formas que el propio juego parece no haber previsto.",
            coverHex: "#4C1D95"
        ),
        steamGame(
            id: cyberpunkId,
            igdbId: 1877,
            steamAppId: 1091500,
            title: "Cyberpunk 2077",
            tagline: "En Night City puedes ser quien quieras. Si sobrevives.",
            genres: ["RPG", "Acción", "Mundo abierto"],
            platforms: ["PC", "PlayStation", "Xbox"],
            year: 2020,
            rating: 4.4,
            votes: 24100,
            metascore: 86,
            developer: "CD Projekt Red",
            publisher: "CD Projekt",
            synopsis: "Como V, mercenario en busca de un implante que promete la inmortalidad, recorrerás una megalópolis obsesionada con el poder y la modificación corporal. Tras años de parches y la expansión Phantom Liberty, es por fin el juego que prometía ser.",
            coverHex: "#A16207"
        ),
        steamGame(
            id: redDead2Id,
            igdbId: 25076,
            steamAppId: 1174180,
            title: "Red Dead Redemption 2",
            tagline: "Los forajidos de siempre ya no tienen lugar en este mundo.",
            genres: ["Acción", "Aventura", "Mundo abierto"],
            platforms: ["PC", "PlayStation", "Xbox"],
            year: 2018,
            rating: 4.8,
            votes: 35700,
            metascore: 97,
            mode: "1 jugador · Multijugador en línea",
            developer: "Rockstar Games",
            publisher: "Rockstar Games",
            synopsis: "América, 1899. Arthur Morgan y la banda de Van der Linde huyen tras un golpe fallido mientras el Salvaje Oeste se extingue. Un mundo de un detalle casi obsesivo que te pide ir despacio y una de las historias mejor contadas del medio.",
            coverHex: "#7C2D12"
        ),
        steamGame(
            id: hadesId,
            igdbId: 113112,
            steamAppId: 1145360,
            title: "Hades",
            tagline: "Desafía al dios de los muertos y escapa del Inframundo.",
            genres: ["Acción", "Roguelike", "Indie"],
            platforms: ["PC", "Mac", "Nintendo Switch", "PlayStation", "Xbox", "iOS"],
            year: 2020,
            rating: 4.9,
            votes: 22400,
            metascore: 93,
            developer: "Supergiant Games",
            publisher: "Supergiant Games",
            synopsis: "Zagreo, hijo de Hades, intenta escapar de casa una y otra vez con la ayuda de los dioses del Olimpo. Cada muerte hace avanzar la historia: el roguelike que convirtió volver a empezar en una recompensa.",
            coverHex: "#991B1B"
        ),
        steamGame(
            id: cupheadId,
            steamAppId: 268910,
            title: "Cuphead",
            tagline: "No hagas tratos con el Diablo.",
            genres: ["Acción", "Plataformas", "Indie"],
            platforms: ["PC", "Mac", "Nintendo Switch", "PlayStation", "Xbox"],
            year: 2017,
            rating: 4.6,
            votes: 13800,
            metascore: 88,
            mode: "1-2 jugadores",
            developer: "Studio MDHR",
            publisher: "Studio MDHR",
            synopsis: "Un run and gun centrado en combates contra jefes, animado a mano cuadro por cuadro al estilo de los dibujos de los años 30, con fondos en acuarela y una banda sonora de jazz grabada en vivo. Tan precioso como exigente.",
            coverHex: "#B45309"
        ),
        steamGame(
            id: deadCellsId,
            steamAppId: 588650,
            title: "Dead Cells",
            tagline: "Mata. Muere. Aprende. Repite.",
            genres: ["Acción", "Roguelike", "Metroidvania", "Indie"],
            platforms: ["PC", "Mac", "Nintendo Switch", "PlayStation", "Xbox", "iOS"],
            year: 2018,
            rating: 4.6,
            votes: 12100,
            metascore: 89,
            developer: "Motion Twin",
            publisher: "Motion Twin",
            synopsis: "Explora un castillo que cambia en cada intento con un combate 2D rapidísimo y decenas de armas que alteran tu forma de jugar. Sin puntos de control: solo lo que aprendiste en la partida anterior.",
            coverHex: "#0F766E"
        ),
        steamGame(
            id: portal2Id,
            igdbId: 72,
            steamAppId: 620,
            title: "Portal 2",
            tagline: "La ciencia continúa. Con o sin ti.",
            genres: ["Puzle", "Plataformas", "Aventura"],
            platforms: ["PC", "Mac", "Nintendo Switch", "PlayStation", "Xbox"],
            year: 2011,
            rating: 4.9,
            votes: 33400,
            metascore: 95,
            mode: "1-2 jugadores",
            developer: "Valve",
            publisher: "Valve",
            synopsis: "Chell despierta en unas instalaciones de Aperture Science en ruinas y GLaDOS no la ha olvidado. Puzles con portales, geles y rayos que introducen una idea nueva en cada sala, y uno de los guiones más divertidos que ha dado el medio.",
            coverHex: "#1E40AF"
        ),
        steamGame(
            id: undertaleId,
            igdbId: 12517,
            steamAppId: 391540,
            title: "Undertale",
            tagline: "El RPG donde no tienes que destruir a nadie.",
            genres: ["RPG", "Indie"],
            platforms: ["PC", "Mac", "Nintendo Switch", "PlayStation", "Xbox"],
            year: 2015,
            rating: 4.8,
            votes: 20900,
            metascore: 92,
            developer: "Toby Fox",
            publisher: "Toby Fox",
            synopsis: "Un humano cae al mundo subterráneo de los monstruos. Puedes pelear o hablar con cada enemigo, y el juego recuerda lo que hiciste. Creado casi por completo por una sola persona, música incluida.",
            coverHex: "#111827"
        ),
        steamGame(
            id: outerWildsId,
            steamAppId: 753640,
            title: "Outer Wilds",
            tagline: "El sistema solar se acaba en 22 minutos. Otra vez.",
            genres: ["Aventura", "Puzle", "Indie"],
            platforms: ["PC", "Nintendo Switch", "PlayStation", "Xbox"],
            year: 2019,
            rating: 4.8,
            votes: 14700,
            metascore: 85,
            developer: "Mobius Digital",
            publisher: "Annapurna Interactive",
            synopsis: "Eres el nuevo recluta de un programa espacial artesanal, atrapado en un bucle temporal. No hay mejoras ni niveles: lo único que conservas entre un ciclo y otro es lo que tú has entendido. Conviene jugarlo sabiendo lo menos posible.",
            coverHex: "#9A3412"
        ),
        steamGame(
            id: godOfWarId,
            igdbId: 19560,
            steamAppId: 1593500,
            title: "God of War",
            tagline: "Un padre, un hijo y las cenizas de una promesa.",
            genres: ["Acción", "Aventura"],
            platforms: ["PC", "PlayStation"],
            year: 2018,
            rating: 4.8,
            votes: 29300,
            metascore: 94,
            developer: "Santa Monica Studio",
            publisher: "PlayStation Studios",
            synopsis: "Kratos dejó atrás el Olimpo y ahora cría a su hijo Atreus en las tierras de los dioses nórdicos. Un viaje contado en un único plano secuencia, con un combate contundente y una relación que cambia a cada paso.",
            coverHex: "#1E3A5F"
        )
    ]

    // MARK: - Reseñas Ampliadas
    static let extendedReviews: [Review] = [
        Review(
            id: darkSoulsReviewId,
            gameId: darkSoulsId,
            authorId: renatoId,
            authorUsername: "renato.q",
            authorName: "Renato Quintanilla",
            rating: 4.8,
            title: "El mapa mejor diseñado que he recorrido",
            text: "Abrir el ascensor de la Parroquia y aparecer en el Santuario de Enlace de Fuego es el momento en que entiendes el juego. La segunda mitad baja el nivel, pero Lordran sigue sin tener rival.",
            likesCount: 41,
            createdAt: daysAgo(0.2)
        ),
        Review(
            id: skyrimReviewId,
            gameId: skyrimId,
            authorId: mauroId,
            authorUsername: "mauro.b",
            authorName: "Mauro Barcenas",
            rating: 4.7,
            title: "Iba a hacer la misión principal. Llevo 90 horas sin tocarla",
            text: "El combate es simple y los bugs son parte del folclore, pero ningún otro mundo me ha hecho desviarme tantas veces del camino. Ver una ruina a lo lejos y poder entrar sigue siendo magia.",
            likesCount: 37,
            createdAt: daysAgo(0.6)
        ),
        Review(
            id: eldenRingReviewId,
            gameId: eldenRingId,
            authorId: marinaId,
            authorUsername: "marina.codes",
            authorName: "Marina Ríos",
            rating: 5.0,
            title: "Dirección de arte que te guía sin un solo marcador",
            text: "El Árbol Áureo visible desde cualquier punto funciona como brújula y como promesa. Cada región tiene su paleta y su silueta; me detuve a hacer capturas más veces que a pelear.",
            likesCount: 52,
            createdAt: daysAgo(1)
        ),
        Review(
            id: witcherReviewId,
            gameId: witcher3Id,
            authorId: renatoId,
            authorUsername: "renato.q",
            authorName: "Renato Quintanilla",
            rating: 4.9,
            title: "Las misiones secundarias que cambiaron el estándar",
            text: "La historia del Barón Sanguinario vale más que campañas enteras de otros RPG. El combate es lo más flojo, pero la escritura y la música lo compensan con creces.",
            likesCount: 33,
            createdAt: daysAgo(2)
        ),
        Review(
            gameId: darkSouls3Id,
            authorId: mauroId,
            authorUsername: "mauro.b",
            authorName: "Mauro Barcenas",
            rating: 4.6,
            title: "Los mejores jefes de la trilogía",
            text: "Más lineal que el primero, pero el combate es el más fino de la saga. El Rey Sin Nombre y Gael son de esas peleas que recuerdas años después.",
            likesCount: 22,
            createdAt: daysAgo(3)
        ),
        Review(
            gameId: sekiroId,
            authorId: renatoId,
            authorUsername: "renato.q",
            authorName: "Renato Quintanilla",
            rating: 4.6,
            title: "Un juego de ritmo disfrazado de juego de ninjas",
            text: "Me costó dejar de esquivar como en Dark Souls. Cuando por fin entiendes que hay que desviar, el duelo con Genichiro se vuelve una coreografía. Durísimo, pero justo.",
            likesCount: 18,
            createdAt: daysAgo(4)
        ),
        Review(
            gameId: baldursGate3Id,
            authorId: marinaId,
            authorUsername: "marina.codes",
            authorName: "Marina Ríos",
            rating: 4.9,
            title: "Cada personaje parece el protagonista de su propio juego",
            text: "La captura de movimiento en todos los diálogos cambia cómo se siente un RPG de este tamaño. Resolví un combate entero empujando a un jefe por un barranco y el juego simplemente lo aceptó.",
            likesCount: 29,
            createdAt: daysAgo(5)
        ),
        Review(
            gameId: hadesId,
            authorId: mauroId,
            authorUsername: "mauro.b",
            authorName: "Mauro Barcenas",
            rating: 4.9,
            title: "Perder nunca había sido tan entretenido",
            text: "Cada vez que muero quiero volver a la Casa de Hades para ver qué tienen que decir los personajes. La narrativa encaja con la estructura roguelike mejor que en ningún otro juego.",
            likesCount: 26,
            createdAt: daysAgo(6)
        ),
        Review(
            gameId: redDead2Id,
            authorId: renatoId,
            authorUsername: "renato.q",
            authorName: "Renato Quintanilla",
            rating: 4.7,
            title: "Lento a propósito, y por eso funciona",
            text: "Los controles son pesados y las misiones no dejan improvisar, pero ningún mundo abierto se siente tan vivo. El último tramo de la historia de Arthur me dejó en silencio un buen rato.",
            likesCount: 31,
            createdAt: daysAgo(8)
        ),
        Review(
            gameId: portal2Id,
            authorId: marinaId,
            authorUsername: "marina.codes",
            authorName: "Marina Ríos",
            rating: 4.9,
            title: "No le sobra ni una sala",
            text: "Cada mecánica se presenta, se complica y se retira antes de cansar. Y el cooperativo es de lo mejor que se puede jugar con otra persona en el mismo sofá.",
            likesCount: 20,
            createdAt: daysAgo(10)
        ),
        Review(
            gameId: outerWildsId,
            authorId: mauroId,
            authorUsername: "mauro.b",
            authorName: "Mauro Barcenas",
            rating: 5.0,
            title: "Ojalá pudiera olvidarlo para jugarlo de nuevo",
            text: "No puedo contar nada sin estropearlo. Solo diré que la única progresión está en tu cabeza y que el final me acompañó durante semanas.",
            likesCount: 35,
            createdAt: daysAgo(12)
        ),
        Review(
            gameId: undertaleId,
            authorId: renatoId,
            authorUsername: "renato.q",
            authorName: "Renato Quintanilla",
            rating: 4.7,
            title: "Un RPG que te observa mientras juegas",
            text: "Parece un homenaje sencillo a EarthBound hasta que empieza a recordar tus decisiones. La banda sonora no tiene un tema malo.",
            likesCount: 17,
            createdAt: daysAgo(15)
        ),
        Review(
            gameId: cyberpunkId,
            authorId: marinaId,
            authorUsername: "marina.codes",
            authorName: "Marina Ríos",
            rating: 4.3,
            title: "Night City es el verdadero personaje",
            text: "Como diseño de ciudad es abrumadora: neones, capas verticales y una identidad distinta por distrito. La historia principal se queda corta, aunque Phantom Liberty lo arregla en gran parte.",
            likesCount: 14,
            createdAt: daysAgo(18)
        )
    ]

    // MARK: - Comentarios Ampliados
    static let extendedComments: [ReviewComment] = [
        ReviewComment(
            reviewId: darkSoulsReviewId,
            authorId: mauroId,
            authorUsername: "mauro.b",
            authorName: "Mauro Barcenas",
            text: "Ese ascensor es el mejor atajo de la historia. Y coincido: después de Anor Londo se nota la prisa.",
            createdAt: daysAgo(0.15)
        ),
        ReviewComment(
            reviewId: darkSoulsReviewId,
            authorId: marinaId,
            authorUsername: "marina.codes",
            authorName: "Marina Ríos",
            text: "Ver Anor Londo por primera vez desde arriba sigue siendo una de las mejores revelaciones visuales del medio.",
            createdAt: daysAgo(0.1)
        ),
        ReviewComment(
            reviewId: skyrimReviewId,
            authorId: renatoId,
            authorUsername: "renato.q",
            authorName: "Renato Quintanilla",
            text: "Nadie termina la misión principal de Skyrim, es una tradición. ¿Ya entraste a Blackreach?",
            createdAt: daysAgo(0.5)
        ),
        ReviewComment(
            reviewId: eldenRingReviewId,
            authorId: mauroId,
            authorUsername: "mauro.b",
            authorName: "Mauro Barcenas",
            text: "Bajar por primera vez al río Siofra y ver ese cielo falso de estrellas… no me lo esperaba para nada.",
            createdAt: daysAgo(0.9)
        ),
        ReviewComment(
            reviewId: witcherReviewId,
            authorId: marinaId,
            authorUsername: "marina.codes",
            authorName: "Marina Ríos",
            text: "Y Blood and Wine es prácticamente otro juego. Toussaint tiene la mejor paleta de color de toda la saga.",
            createdAt: daysAgo(1.5)
        )
    ]
}
