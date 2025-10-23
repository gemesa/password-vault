import Foundation
import SwiftUI

struct EditPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vaultViewModel: VaultViewModel
    let entryToEdit: PasswordEntryWrapper

    @State private var title = ""
    @State private var username = ""
    @State private var password = ""
    @State private var notes = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    init(vaultViewModel: VaultViewModel, entryToEdit: PasswordEntryWrapper) {
        self.vaultViewModel = vaultViewModel
        self.entryToEdit = entryToEdit

        _title = State(initialValue: entryToEdit.title)
        _username = State(initialValue: entryToEdit.username)
        _password = State(initialValue: entryToEdit.password)
        _notes = State(initialValue: entryToEdit.notes ?? "")
    }

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
            .navigationTitle("Edit entry")
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

        if vaultViewModel.updateEntry(
            entryToEdit,
            title: title,
            username: username,
            password: password,
            notes: notesValue, vaultPassword: password)
        {
            dismiss()
        } else {
            alertMessage = "Failed to update password"
            showAlert = true
        }
    }
}
