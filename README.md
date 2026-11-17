# GameRev · Red Social para los Amantes del Gaming y Creadores

**Lab iOS · Periodo Ago–Dic 2026 · Equipo 6**  
**Profesor:** Azael Flores  

### Integrantes del Equipo 6
- **Mauro Ernesto Medrano Barcenas** (FIME)
- **Irving Tadeo Saldaña Gaytan** (FIME)
- **Angel David Gomez Dominguez** (FCFM)
- **Renato Quintanilla Solis** (FCFM)

---

## Estructura del Proyecto

```text
GameRev/
├── GameRev.xcodeproj/                 # Proyecto nativo de Xcode listo para abrir en macOS (iOS 16+ / macOS 13+)
├── Package.swift                      # Swift Package alternativo para abrir en Xcode o VS Code
├── Config/
│   ├── GameRev.xcconfig               # Configuración base (se sube al repo)
│   └── Secrets.example.xcconfig       # Plantilla de credenciales IGDB; cópiala como Secrets.xcconfig (ignorado por git)
├── GameRev/
│   ├── GameRevApp.swift               # Punto de entrada @main de la aplicación SwiftUI
│   ├── Info.plist                     # Configuración del bundle de iOS/macOS
│   ├── Assets.xcassets/               # Catálogo de recursos (AccentColor y AppIcon)
│   ├── Models/
│   │   └── Models.swift               # Entidades Codable, enums de estado, acciones pendientes y errores recuperables
│   ├── Services/
│   │   ├── AppStateStore.swift        # @MainActor ObservableObject con lógica de negocio, auth, permisos y persistencia JSON
│   │   ├── IGDBConfig.swift           # Lee IGDB_CLIENT_ID / IGDB_CLIENT_SECRET del entorno o de Info.plist
│   │   ├── IGDBService.swift          # Cliente IGDB v4: OAuth 2.0 de Twitch, reintentos, caché y respaldo con catálogo local
│   │   ├── SeedData.swift             # Datos semilla alineados con el Storyboard (Hollow Knight, Hades II, Celeste, Silksong, Sea of Stars)
│   │   └── SeedCatalog.swift          # Ampliación del catálogo (Dark Souls, Skyrim, Elden Ring, The Witcher 3…) y sus reseñas
│   └── Views/
│       ├── RootContentView.swift      # Escenas 1 y 2: Splash (Session Check), Bienvenido, TabView (iPhone) y NavigationSplitView (MacBook/iPad)
│       ├── HomeView.swift             # Inicio adaptativo (tarjetas móviles en iPhone y Dashboard multicolumna en MacBook)
│       ├── AuthViews.swift            # Escenas 1 y 5: Bienvenido, Login, Registro, Modo Lector y recuperación de pendingAction
│       ├── CatalogView.swift          # Escena 3: Búsqueda IGDB, filtros (Género, Plataforma, Año), CONNECTION_ERROR y EMPTY_RESULTS
│       ├── GameDetailView.swift       # Escena 4: Ficha del videojuego y sus 4 acciones programables conectadas
│       ├── DiaryView.swift            # Escenas 6 y 7: Mi diario, filtros por estado/categoría, Empty State y Categorías personalizadas
│       ├── ReviewsView.swift          # Escena 8: Mini-reseñas, contador de caracteres, validación y Detalle de reseña con comentarios
│       ├── ProfileViews.swift         # Escenas 9, 10 y 11: Perfil público de creador, Mi perfil, Edición condicional y Control de permisos
│       └── Components/
│           ├── Theme.swift            # Sistema de diseño: paleta claro/oscuro, espaciados, tarjetas y estilos de botón
│           └── UIComponents.swift     # Portadas, pósters, avatares, esqueletos de carga, tarjetas de error recuperable (Escena 12) e Inspector del Lab
└── WebPrototype/
    └── index.html                     # Prototipo Web interactivo completo (iPhone + MacBook + Selector de las 13 Escenas) para Windows/navegador
```

---

## Correspondencia con los Diagramas de Flujo (Actividad 2) y las 13 Escenas (Actividad 3)

| Escena / Diagrama | Descripción Funcional | Archivo SwiftUI Principal |
| :--- | :--- | :--- |
| **Escena 01 · Arranque** *(Diag. 01 y 02)* | `SESSION CHECK`: muestra pantalla de carga `"Preparando tu experiencia"`, recupera sesión persistida o dirige a `"Bienvenido"` (`Entrar como lector`, `Iniciar sesión`, `Crear cuenta`). | `RootContentView.swift`, `AuthViews.swift` |
| **Escena 02 · Menú Principal** *(Diag. 01)* | Navegación adaptativa: `TabView` inferior en iPhone (`compact`) y `NavigationSplitView` con Sidebar y paneles multicolumna en MacBook/iPad (`regular`). | `RootContentView.swift`, `HomeView.swift` |
| **Escena 03 · Catálogo e IGDB** *(Diag. 03)* | Barra de búsqueda y filtros por `Género`, `Plataforma` y `Año`. Consulta `IGDBService` y maneja error de conexión (`No pudimos conectar` + `Reintentar`) y búsqueda vacía (`Sin resultados`). | `CatalogView.swift`, `IGDBService.swift` |
| **Escena 04 · Ficha del Videojuego** *(Diag. 03)* | Muestra portada (`HK`, `HA`, `CE`, etc.), valoración (`4.7 / 5`), año, modo (`1 jugador`), sinopsis y las 4 acciones programables: `Guardar en mi diario`, `Leer reseñas`, `Escribir reseña` y `Ver creador`. | `GameDetailView.swift` |
| **Escena 05 · Acción Protegida** *(Diag. 02)* | Cuando un lector intenta una acción de escritura, guarda `pendingAction = "Guardar Hollow Knight"` y abre `"Acceso requerido"`. Al iniciar sesión o crear cuenta, retoma automáticamente la acción pendiente. | `AppStateStore.swift`, `AuthViews.swift` |
| **Escena 06 · Diario Personal** *(Diag. 04)* | Filtra por los 5 estados (`Pendiente`, `Jugando`, `Completado`, `Abandonado`, `Rejugando`) y por categoría personalizada. Contempla el estado vacío (`"Tu diario está vacío"` + `"Buscar videojuegos"`). | `DiaryView.swift` |
| **Escena 07 · Categorías Personalizadas** *(Diag. 04)* | Creación y renombrado de categorías con validación de nombre válido y único (`× Nombre duplicado`), conservando el texto para corregir. | `DiaryView.swift` (`CategoriesManagementSheet`) |
| **Escena 08 · Mini-reseñas y Comentarios** *(Diag. 05)* | Lectura pública, publicación de mini-reseña con límite de 280 caracteres y validación de texto no vacío, y vista `Detalle de reseña` con hilo de comentarios. | `ReviewsView.swift` |
| **Escena 09 · Perfil Público de Creador** *(Diag. 06)* | Muestra identidad (`Team Cherry`, `Marina Ríos`), badge (`CREADOR · ESTUDIO`), `Trayectoria`, `Trabajos / Portafolio` y botón externo `"Visitar sitio de contacto"`. | `ProfileViews.swift` (`PublicProfileView`) |
| **Escena 10 · Mi Perfil y Edición Condicional** *(Diag. 07)* | En `"Editar perfil"`, cambiar el selector `TIPO DE PERFIL` de `Jugador` a `Creador` habilita dinámicamente los campos de `Estudio`, `Rol`, `Trayectoria`, `Portafolio` y `Enlace público`. | `ProfileViews.swift` (`EditProfileSheet`) |
| **Escena 11 · Control de Permisos** *(Diag. 06 y 07)* | Verifica `currentUser.id == profile.ownerId` antes de permitir cualquier escritura. En perfiles ajenos bloquea la edición (`Modo consulta` vs `Modo edición`). | `ProfileViews.swift`, `AppStateStore.swift` |
| **Escena 12 · Manejo de Errores** | Tarjetas recuperables para `CONNECTION_ERROR`, `EMPTY_RESULTS`, `AUTH_ERROR`, `INVALID_FORM` y `UNAUTHORIZED`. | `UIComponents.swift` (`RecoverableErrorCardView`) |
| **Escena 13 · Mapa General e Inspector** | Inspector integrado (`•••` en la barra superior) para probar todas las escenas y simulaciones durante la demostración en el laboratorio. | `UIComponents.swift` (`LabInspectorSheetView`) |

---

## Cómo Ejecutar el Proyecto

### Opción A: En una Mac del Laboratorio iOS (Xcode)
1. Copia la carpeta `GameRev` a la Mac del laboratorio.
2. Abre `GameRev.xcodeproj` en **Xcode** (compatible con Xcode 14, 15 y 16+; iOS 16+ / macOS 13+).
3. Selecciona un simulador de **iPhone** (para ver el `TabView` móvil), **iPad** o **My Mac** (para ver el `NavigationSplitView` adaptativo de escritorio).
4. Presiona **Run (`⌘R`)**.


### Opción B: En Windows o Cualquier Navegador (Prototipo Web Interactivo)
1. Abre el archivo `WebPrototype/index.html` haciendo doble clic desde el Explorador de Archivos de Windows.
2. Utiliza la barra lateral izquierda para saltar entre las **13 Escenas del Storyboard** o usa el simulador de **iPhone (`TabView`)** y **MacBook (`NavigationSplitView`)** en tiempo real.
