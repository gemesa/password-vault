import Foundation
import SwiftUI

struct PasswordRowView: View {
    let entry: PasswordEntryWrapper
    @State private var showCopiedFeedback = false
    @State private var copiedType: String = ""

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                Text(entry.username)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    copyToClipboard(entry.username, type: "Username")
                } label: {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.black)
                }
                .buttonStyle(.borderless)

                Button {
                    copyToClipboard(entry.password, type: "Password")
                } label: {
                    Image(systemName: "key.fill")
                        .foregroundColor(.black)
                }
                .buttonStyle(.borderless)
            }
        }
        .overlay(
            Group {
                if showCopiedFeedback {
                    Text("\(copiedType) copied!")
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.opacity)
                }
            }
        )
    }

    private func copyToClipboard(_ text: String, type: String) {
        UIPasteboard.general.string = text
        copiedType = type

        withAnimation {
            showCopiedFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCopiedFeedback = false
            }
        }
    }
}
