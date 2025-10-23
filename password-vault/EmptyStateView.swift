import Foundation
import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
            Text("No passwords yet")
                .font(.title2)
            Text("Tap + to add your first password")
        }
    }
}
