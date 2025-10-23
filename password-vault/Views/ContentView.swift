import CryptoKit
import SwiftUI

struct ContentView: View {

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
        case loadVaultError = "Failed to load vault"
        case saveVaultError = "Failed to save vault after setting a new password"
    }

    @StateObject private var vaultViewModel = VaultViewModel()
    @State private var showAddSheet = false
    @State private var state = States.loggedOut
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var password = ""
    @State private var showResetConfirmation = false
    @State private var entryToEdit: PasswordEntryWrapper?

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
            ResetView(
                action: handleReset,
                password: $password,
                showAlert: $showAlert,
                alertMessage: $alertMessage
            )
        default:
            LoginView(
                buttonTitle: buttonText,
                action: handleLogin,
                password: $password,
                showAlert: $showAlert,
                alertMessage: $alertMessage
            )
        }
    }

    private func showAlert(_ message: AlertMessage) {
        alertMessage = message.rawValue
        showAlert = true
    }

    private func handleLogin() {
        if hasPassword {
            guard VaultPasswordManager.verifyVaultPassword(password) else {
                showAlert(.wrongPassword)
                return
            }

            guard vaultViewModel.loadVault(vaultPassword: password) else {
                showAlert(.loadVaultError)
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

    private func handleReset() {
        guard PasswordValidator.isPasswordValid(password) else {
            showAlert(.weakPassword)
            return
        }

        let backup = VaultPasswordManager.backupVaultPassword()

        guard VaultPasswordManager.deleteVaultPassword() else {
            showAlert(.resetError)
            return
        }
        guard VaultPasswordManager.setVaultPassword(password) else {
            if let backup = backup {
                _ = VaultPasswordManager.restoreVaultPassword(from: backup)
            }
            showAlert(.resetError)
            return
        }
        guard vaultViewModel.saveVault(vaultPassword: password) else {
            _ = VaultPasswordManager.deleteVaultPassword()
            if let backup = backup {
                _ = VaultPasswordManager.restoreVaultPassword(from: backup)
            }
            showAlert(.saveVaultError)
            return
        }
        password = ""
        state = .loggedOut
    }

    private var mainView: some View {
        NavigationStack {
            ZStack {
                Color(.darkGray)
                    .ignoresSafeArea()

                if vaultViewModel.entries.isEmpty {
                    EmptyStateView()
                } else {
                    PasswordListView(
                        vaultViewModel: vaultViewModel,
                        entryToEdit: $entryToEdit,
                        vaultPassword: password)
                }

            }
            .navigationTitle("Vault")
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Logout") {
                            password = ""
                            state = .loggedOut
                        }

                        Button("Reset password") {
                            showResetConfirmation = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Reset password", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    password = ""
                    state = .resettingPassword
                }
            } message: {
                Text("Are you sure you want to reset your vault password?")
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPasswordView(vaultViewModel: vaultViewModel, vaultPassword: password)
        }
        .sheet(item: $entryToEdit) { entry in
            EditPasswordView(
                vaultViewModel: vaultViewModel, entryToEdit: entry, vaultPassword: password)
        }
    }
}

#Preview {
    ContentView()
}
