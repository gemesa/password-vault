import Foundation
import SwiftUI

struct PasswordEntryView: View {
    let title: String
    let buttonTitle: String
    let action: () -> Void

    @Binding var password: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    var body: some View {
        ZStack {
            Color(.darkGray)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.black)

                SecureField("Vault password", text: $password)
                    .frame(maxWidth: 250, maxHeight: 26)
                    .background(Color(.lightGray))
                    .cornerRadius(6)

                Button(buttonTitle, action: action)
                    .buttonStyle(.bordered)
                    .disabled(password.isEmpty)
                    .tint(Color(.black))
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK") {}
        }
    }
}

struct ResetView: View {
    let action: () -> Void

    @Binding var password: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    var body: some View {
        PasswordEntryView(
            title: "Enter new password",
            buttonTitle: "Set new password",
            action: action,
            password: $password,
            showAlert: $showAlert,
            alertMessage: $alertMessage
        )
    }
}

struct LoginView: View {
    let buttonTitle: String
    let action: () -> Void

    @Binding var password: String
    @Binding var showAlert: Bool
    @Binding var alertMessage: String

    var body: some View {
        PasswordEntryView(
            title: "Enter password",
            buttonTitle: buttonTitle,
            action: action,
            password: $password,
            showAlert: $showAlert,
            alertMessage: $alertMessage
        )
    }
}
