import CryptoKit
import SwiftUI

struct ContentView: View {
    private func showAlert(_ message: AlertMessage) {
        alertMessage = message.rawValue
        showAlert = true
    }
    enum States {
        case loggedIn
        case loggedOut
        case resettingPassword
    }
    enum AlertMessage: String {
        case wrongPassword = "Wrong password"
        case weakPassword = "Weak password"
        case resetError = "Something went wrong while resetting the vault password"
        case setError = "Something went wrong while setting the vault password"
    }
    @State private var state = States.loggedOut
    @State var showAlert = false
    @State var alertMessage = ""
    @State var password = ""

    var buttonText: String {
        hasPassword ? "Unlock" : "Set password"
    }

    var hasPassword: Bool {
        VaultPasswordManager.hasVaultPassword()
    }

    var body: some View {
        switch state {
        case .loggedIn:
            mainView
        case .resettingPassword:
            resetView
        default:
            loginView
        }
    }

    private var mainView: some View {
        ZStack {
            Color(.darkGray)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Button("Logout") {
                    state = .loggedOut
                }
                .buttonStyle(.bordered)
                .tint(.orange)

                Button("Reset") {
                    state = .resettingPassword
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
    }

    private var resetView: some View {
        ZStack {
            Color(.darkGray)
                .ignoresSafeArea()
            VStack(spacing: 20) {

                Text("Enter new password")
                    .font(.title2)
                    .foregroundColor(.white)

                SecureField("Vault password", text: $password)
                    .frame(maxWidth: 300)
                    .textFieldStyle(.roundedBorder)
                Button("Set new password") {
                    defer { password = "" }
                    guard PasswordValidator.isPasswordValid(password) else {
                        showAlert(.weakPassword)
                        return
                    }
                    guard VaultPasswordManager.deleteVaultPassword() else {
                        showAlert(.resetError)
                        return
                    }
                    guard VaultPasswordManager.setVaultPassword(password) else {
                        showAlert(.resetError)
                        return
                    }
                    state = .loggedOut

                }
                .buttonStyle(.bordered)
                .tint(.mint)
                .disabled(password.isEmpty)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {}
        }
    }

    private var loginView: some View {

        ZStack {
            Color(.darkGray)
                .ignoresSafeArea()
            VStack(spacing: 20) {

                Text("Enter password")
                    .font(.title2)
                    .foregroundColor(.white)

                SecureField("Vault password", text: $password)
                    .frame(maxWidth: 300)
                    .textFieldStyle(.roundedBorder)

                Button(buttonText) {
                    defer { password = "" }
                    if hasPassword {
                        guard VaultPasswordManager.verifyVaultPassword(password) else {
                            showAlert(.wrongPassword)
                            return
                        }
                        state = .loggedIn
                        return
                    }
                    guard PasswordValidator.isPasswordValid(password) else {
                        showAlert(.weakPassword)
                        return
                    }
                    guard VaultPasswordManager.setVaultPassword(password) else {
                        showAlert(.setError)
                        return
                    }
                    state = .loggedIn
                }
                .buttonStyle(.bordered)
                .tint(.mint)
                .disabled(password.isEmpty)
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK") {}
            }
        }
    }
}

#Preview {
    ContentView()
}
