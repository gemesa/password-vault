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
        return hasPassword ? "Unlock" : "Set password"
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
                    print("Logging out")
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
                    if VaultPasswordManager.deleteVaultPassword() {
                        print("Vault password deleted")
                        if VaultPasswordManager.setVaultPassword(password) {
                            print("Vault password successfully reset")
                            print("Logging out")
                            state = .loggedOut
                        } else {
                            print(
                                "Something went wrong while resetting the vault password"
                            )
                        }
                    } else {
                        print(
                            "Something went wrong while resetting the vault password"
                        )
                    }
                }
                .buttonStyle(.bordered)
                .tint(.mint)
                .disabled(password.isEmpty)
            }
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
                        if VaultPasswordManager.verifyVaultPassword(password) {
                            print("Vault password accepted")
                            state = .loggedIn
                        } else {
                            print("Vault password is incorrect")
                            alertMessage = "Wrong password"
                            showAlert = true
                        }
                    } else {
                        if VaultPasswordManager.setVaultPassword(password) {
                            print("Vault password successfully set")
                            state = .loggedIn
                        } else {
                            print(
                                "Something went wrong while setting the vault password"
                            )
                        }
                    }
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
