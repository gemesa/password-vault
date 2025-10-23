import Combine
import Foundation

struct PasswordEntryWrapper: Identifiable {
    let entry: PasswordEntry

    var id: UUID { entry.identifier }
    var title: String { entry.title }
    var username: String { entry.username }
    var password: String { entry.password }
    var notes: String? { entry.notes }
}

class VaultViewModel: ObservableObject {
    @Published var entries: [PasswordEntryWrapper] = []

    private let vaultStorageManager: VaultStorageManager

    init() {
        self.vaultStorageManager = VaultStorageManager()
    }

    func loadVault(vaultPassword: String) -> Bool {
        let result = vaultStorageManager.loadVault(withPassword: vaultPassword)
        if result == .success {
            entries = vaultStorageManager.allEntries().map { PasswordEntryWrapper(entry: $0) }
            return true
        }
        return false
    }

    func saveVault(vaultPassword: String) -> Bool {
        let result = vaultStorageManager.saveVault(withPassword: vaultPassword)
        return result == .success
    }

    func addEntry(
        title: String, username: String, password: String, notes: String?, vaultPassword: String
    ) -> Bool {
        let entry = PasswordEntry(
            title: title, username: username, password: password, notes: notes)
        let result = vaultStorageManager.add(entry, withPassword: vaultPassword)
        if result == .success {
            entries.append(PasswordEntryWrapper(entry: entry))
            return true
        }
        return false
    }

    func deleteEntry(_ wrapper: PasswordEntryWrapper, vaultPassword: String) -> Bool {
        let result = vaultStorageManager.delete(wrapper.entry, withPassword: vaultPassword)
        if result == .success {
            if let index = entries.firstIndex(where: { $0.id == wrapper.id }) {
                entries.remove(at: index)
            }
            return true
        }
        return false
    }

    func deleteEntries(at offsets: IndexSet, vaultPassword: String) {
        for index in offsets {
            let wrapper = entries[index]
            _ = deleteEntry(wrapper, vaultPassword: vaultPassword)
        }
    }

    func updateEntry(
        _ wrapper: PasswordEntryWrapper, title: String, username: String, password: String,
        notes: String?, vaultPassword: String
    ) -> Bool {
        let updatedEntry = PasswordEntry(
            identifier: wrapper.id,
            title: title,
            username: username,
            password: password,
            notes: notes
        )
        let result = vaultStorageManager.update(updatedEntry, withPassword: vaultPassword)
        if result == .success {
            if let index = entries.firstIndex(where: { $0.id == wrapper.id }) {
                entries[index] = PasswordEntryWrapper(entry: updatedEntry)
            }
            return true
        }
        return false
    }
}
