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
    }

    @StateObject private var vaultViewModel = VaultViewModel()
    @State private var showAddSheet = false
    @State private var state = States.loggedOut
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var password = ""
    @State private var showResetConfirmation = false

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

    private func showAlert(_ message: AlertMessage) {
        alertMessage = message.rawValue
        showAlert = true
    }

    private func handleLogin() {
        defer { password = "" }
        if hasPassword {
            guard VaultPasswordManager.verifyVaultPassword(password) else {
                showAlert(.wrongPassword)
                return
            }

            guard vaultViewModel.loadVault() else {
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

    private var mainView: some View {
        NavigationStack {
            ZStack {
                Color(.darkGray)
                    .ignoresSafeArea()

                if vaultViewModel.entries.isEmpty {
                    emptyStateView
                } else {
                    passwordListView
                }

            }
            .navigationTitle("Vault")
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
            .alert("Reset Password", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    state = .resettingPassword
                }
            } message: {
                Text("Are you sure you want to reset your vault password?")
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddPasswordView(vaultViewModel: vaultViewModel)
        }
    }

    @ViewBuilder
    private func passwordEntryView(
        title: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        ZStack {
            Color(.darkGray)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.white)

                SecureField("Vault password", text: $password)
                    .frame(maxWidth: 300)
                    .textFieldStyle(.roundedBorder)

                Button(buttonTitle, action: action)
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(password.isEmpty)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {}
        }
    }

    private var resetView: some View {
        passwordEntryView(
            title: "Enter new password",
            buttonTitle: "Set new password",
            action: handleReset
        )
    }

    private var loginView: some View {
        passwordEntryView(
            title: "Enter password",
            buttonTitle: buttonText,
            action: handleLogin
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
            Text("No passwords yet")
                .font(.title2)
            Text("Tap + to add your first password")
        }
    }

    private var passwordListView: some View {
        List {
            ForEach(vaultViewModel.entries) { entry in
                PasswordRowView(entry: entry)
            }
            .listRowBackground(Color(.lightGray))
        }
        .scrollContentBackground(.hidden)
        .background(Color(.darkGray))

    }
}

struct PasswordRowView: View {
    let entry: PasswordEntryWrapper

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title)
            Text(entry.username)
        }
    }
}

struct AddPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vaultViewModel: VaultViewModel

    @State private var title = ""
    @State private var username = ""
    @State private var password = ""
    @State private var notes = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Username/email", text: $username)
                    SecureField("Password", text: $password)
                } header: {
                    Text("Entry details")
                        .foregroundColor(.black)
                }
                .listRowBackground(Color(.lightGray))

                Section {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                } header: {
                    Text("Notes (optional)")
                        .foregroundColor(.black)
                }
                .listRowBackground(Color(.lightGray))
            }
            .navigationTitle("Add entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(!isValid)
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK") {}
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(.darkGray))
    }

    private var isValid: Bool {
        !title.isEmpty && !username.isEmpty && !password.isEmpty
    }

    private func saveEntry() {
        let notesValue = notes.isEmpty ? nil : notes

        if vaultViewModel.addEntry(
            title: title,
            username: username,
            password: password,
            notes: notesValue)
        {
            dismiss()
        } else {
            alertMessage = "Failed to save password"
            showAlert = true
        }
    }
}

#Preview {
    ContentView()
}
