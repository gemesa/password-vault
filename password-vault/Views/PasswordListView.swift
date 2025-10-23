import Foundation
import SwiftUI

struct PasswordListView: View {
    @ObservedObject var vaultViewModel: VaultViewModel
    @Binding var entryToEdit: PasswordEntryWrapper?
    let vaultPassword: String

    var body: some View {
        List {
            ForEach(vaultViewModel.entries) { entry in
                PasswordRowView(entry: entry)
                    .onTapGesture {
                        entryToEdit = entry
                    }
            }
            .onDelete { offsets in
                vaultViewModel.deleteEntries(at: offsets, vaultPassword: vaultPassword)
            }
            .listRowBackground(Color(.lightGray))
        }
        .scrollContentBackground(.hidden)
        .background(Color(.darkGray))
    }
}
