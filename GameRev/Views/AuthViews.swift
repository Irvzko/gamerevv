//
//  AuthViews.swift
//  GameRev
//
//  Implementa Escena 1 (Arranque y Bienvenido), Diagrama 02 (Acceso como lector,
//  registro e inicio de sesión) y Escena 5 (Acción protegida y recuperación).
//

import SwiftUI

// MARK: - Escena 1 · Splash de Comprobación de Sesión
struct SplashSessionCheckView: View {
    var body: some View {
        ZStack {
            Color.gameRevNavy
                .ignoresSafeArea()

            VStack(spacing: 26) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(hex: "#15233E"))
                        .frame(width: 240, height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(Color.gameRevLink.opacity(0.35), lineWidth: 1.5)
                        )

                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(hex: "#0F172A"))
                                .frame(width: 68, height: 68)
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color.gameRevGold)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("GAMERev")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text("SESSION CHECK")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.gameRevLink)
                        }
                    }
                }

                ProgressView()
                    .tint(Color.gameRevLink)
                    .scaleEffect(1.15)

                Text("Preparando tu experiencia")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
            }
        }
    }
}

// MARK: - Escena 1 · Pantalla Bienvenido (Sin Sesión Activa)
struct WelcomeGateView: View {
    @EnvironmentObject var store: AppStateStore
    @State private var authMode: AuthFormMode? = nil

    enum AuthFormMode: Identifiable {
        case login
        case register
        var id: Self { self }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 28)

                    GameCoverBadge(
                        code: "GR",
                        hexColor: "#0F172A",
                        width: 92,
                        height: 92,
                        cornerRadius: 24,
                        fontSize: 28
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color.gameRevGold.opacity(0.5), lineWidth: 1.5)
                    )

                    VStack(spacing: 8) {
                        Text("Tu mundo de\nvideojuegos")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)

                        Text("Documenta tu historial, comparte mini-reseñas y descubre el talento detrás de cada obra.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    VStack(spacing: 12) {
                        Button {
                            store.enterAsReader()
                        } label: {
                            Text("Entrar como lector")
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

                        Button {
                            authMode = .login
                        } label: {
                            Text("Iniciar sesión")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.primary.opacity(0.06))
                                )
                                .foregroundColor(Color.gameRevBlue)
                        }
                        .buttonStyle(.plain)

                        Button {
                            authMode = .register
                        } label: {
                            Text("Crear cuenta")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.gameRevBlue)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)

                    // Acceso rápido de demostración para el Laboratorio
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CUENTAS DE DEMOSTRACIÓN DEL LAB")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)

                        Button {
                            _ = store.signIn(emailOrUsername: "mauro@gamerev.app", password: "123456")
                        } label: {
                            HStack {
                                AvatarCircleBadge(initials: "AR", size: 36, fontSize: 13)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Mauro Barcenas (Jugador)")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("mauro@gamerev.app · contraseña: 123456")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(Color.gameRevLink)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.gameRevSurface)
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            _ = store.signIn(emailOrUsername: "marina@gamerev.app", password: "123456")
                        } label: {
                            HStack {
                                AvatarCircleBadge(initials: "MR", size: 36, fontSize: 13)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Marina Ríos (Creadora · Ilustración)")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("marina@gamerev.app · contraseña: 123456")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(Color.gameRevLink)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.gameRevSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: 460)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 32)
            }
            .grScreenBackground()
            .navigationTitle("Bienvenido")
            .sheet(item: $authMode) { mode in
                AuthCredentialsSheet(initialMode: mode == .login ? .login : .register)
                    .environmentObject(store)
            }
        }
    }
}

// MARK: - Escena 5 · Acceso Requerido y Recuperación de Acción Pendiente
struct ProtectedActionGateSheet: View {
    @EnvironmentObject var store: AppStateStore
    @State private var showFormMode: AuthCredentialsSheet.Mode? = nil

    var body: some View {
        NavigationStack {
            if let mode = showFormMode {
                AuthCredentialsFormContent(
                    mode: mode,
                    onBackToGate: { showFormMode = nil }
                )
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 16)

                        GameCoverBadge(
                            code: "GR",
                            hexColor: "#0F172A",
                            width: 84,
                            height: 84,
                            cornerRadius: 22,
                            fontSize: 26
                        )

                        VStack(spacing: 8) {
                            Text("Guarda tu progreso")
                                .font(.system(size: 26, weight: .bold, design: .rounded))

                            Text(store.pendingAction?.promptSubtitle ?? "Inicia sesión para añadir este juego a tu diario o publicar.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }

                        if let pending = store.pendingAction {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("CAMBIO DE ESTADO")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.gameRevSuccess)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.gameRevSuccess.opacity(0.14))
                                    .clipShape(Capsule())

                                Text("pendingAction = \"\(pending.descriptionText)\"")
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.primary)

                                Text("Al autenticarse, el sistema retoma automáticamente esta acción en el punto posterior al acceso.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.gameRevSuccess.opacity(0.07))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(Color.gameRevSuccess.opacity(0.28), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 24)
                        }

                        VStack(spacing: 12) {
                            Button {
                                showFormMode = .login
                            } label: {
                                Text("Iniciar sesión")
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

                            Button {
                                showFormMode = .register
                            } label: {
                                Text("Crear cuenta")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.primary.opacity(0.06))
                                    )
                                    .foregroundColor(Color.gameRevBlue)
                            }
                            .buttonStyle(.plain)

                            Button {
                                store.cancelProtectedAction()
                            } label: {
                                Text("Cancelar")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)

                        // Botón rápido para autenticar como Mauro en 1 toque y demostrar la recuperación de pendingAction
                        Button {
                            _ = store.signIn(emailOrUsername: "mauro@gamerev.app", password: "123456")
                        } label: {
                            Label("Autenticar rápido como Mauro Barcenas", systemImage: "bolt.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.gameRevLink.opacity(0.12)))
                                .foregroundColor(Color.gameRevLink)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: 460)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
                .grScreenBackground()
                .navigationTitle("Acceso requerido")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            store.cancelProtectedAction()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Formulario de Inicio de Sesión y Registro con Validación (Diagrama 02 y Escena 12)
struct AuthCredentialsSheet: View {
    enum Mode {
        case login
        case register
    }

    let initialMode: Mode

    var body: some View {
        NavigationStack {
            AuthCredentialsFormContent(mode: initialMode, onBackToGate: nil)
        }
    }
}

struct AuthCredentialsFormContent: View {
    @EnvironmentObject var store: AppStateStore
    @Environment(\.dismiss) private var dismiss

    @State var mode: AuthCredentialsSheet.Mode
    let onBackToGate: (() -> Void)?

    @State private var name: String = ""
    @State private var email: String = "mauro@gamerev.app"
    @State private var password: String = "123456"
    @State private var errorMessage: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("Modo", selection: $mode) {
                    Text("Iniciar sesión").tag(AuthCredentialsSheet.Mode.login)
                    Text("Crear cuenta").tag(AuthCredentialsSheet.Mode.register)
                }
                .pickerStyle(.segmented)
                .onChange(of: mode) { newMode in
                    errorMessage = nil
                    if newMode == .register && email == "mauro@gamerev.app" {
                        email = ""
                        password = ""
                    } else if newMode == .login && email.isEmpty {
                        email = "mauro@gamerev.app"
                        password = "123456"
                    }
                }

                if let errorMessage {
                    RecoverableErrorCardView(
                        errorType: mode == .login ? .authError : .invalidForm,
                        customDetail: errorMessage
                    ) {
                        self.errorMessage = nil
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    if mode == .register {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nombre completo")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            TextField("Ej. Renato Quintanilla", text: $name)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Correo electrónico o usuario")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        TextField("correo@gamerev.app", text: $email)
                            .textFieldStyle(.roundedBorder)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            #endif
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Contraseña")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        SecureField("Contraseña", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Button {
                    submitForm()
                } label: {
                    Text(mode == .login ? "Iniciar sesión" : "Crear cuenta e iniciar sesión")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.gameRevBlue)
                        )
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)

                Button {
                    // Botón de prueba para disparar AUTH_ERROR de la Escena 12
                    errorMessage = RecoverableErrorType.authError.message
                } label: {
                    Label("Probar estado AUTH_ERROR (Escena 12)", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
        }
        .grScreenBackground()
        .navigationTitle(mode == .login ? "Iniciar sesión" : "Crear cuenta")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    if let onBackToGate {
                        onBackToGate()
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }

    private func submitForm() {
        if mode == .login {
            if let error = store.signIn(emailOrUsername: email, password: password) {
                errorMessage = error
            } else {
                dismiss()
            }
        } else {
            if let error = store.registerAccount(name: name, email: email, password: password) {
                errorMessage = error
            } else {
                dismiss()
            }
        }
    }
}
