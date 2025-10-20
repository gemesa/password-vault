import CryptoKit
import SwiftUI

struct ContentView: View {
    enum States {
        case loggedIn
        case loggedOut
        case resettingPassword
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
                        alertMessage = "Weak password"
                        showAlert = true
                        return
                    }
                    guard VaultPasswordManager.deleteVaultPassword() else {
                        alertMessage = "Something went wrong while resetting the vault password"
                        showAlert = true
                        return
                    }
                    guard VaultPasswordManager.setVaultPassword(password) else {
                        alertMessage = "Something went wrong while resetting the vault password"
                        showAlert = true
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
                            alertMessage = "Wrong password"
                            showAlert = true
                            return
                        }
                        state = .loggedIn
                        return
                    }
                    guard PasswordValidator.isPasswordValid(password) else {
                        alertMessage = "Weak password"
                        showAlert = true
                        return
                    }
                    guard VaultPasswordManager.setVaultPassword(password) else {
                        alertMessage = "Something went wrong while setting the vault password"
                        showAlert = true
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
