import Foundation
import SwiftUI

struct PasswordListView: View {
    @ObservedObject var vaultViewModel: VaultViewModel
    @Binding var entryToEdit: PasswordEntryWrapper?

    var body: some View {
        List {
            ForEach(vaultViewModel.entries) { entry in
                PasswordRowView(entry: entry)
                    .onTapGesture {
                        entryToEdit = entry
                    }
            }
            .onDelete(perform: vaultViewModel.deleteEntries)
            .listRowBackground(Color(.lightGray))
        }
        .scrollContentBackground(.hidden)
        .background(Color(.darkGray))
    }
}
