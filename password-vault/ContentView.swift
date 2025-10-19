import CryptoKit
import SwiftUI

struct ContentView: View {
    enum states {
        case loggedIn
        case loggedOut
        case resettingPassword
    }
    @State private var state = states.loggedOut
    @State var showAlert = false
    @State var alertMessage = ""
    @State var password = ""

    var buttonText: String {
        return hasPassword ? "Unlock" : "Set password"
    }

    var hasPassword: Bool {
        MasterPasswordManager.hasMasterPassword()
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

                SecureField("Master password", text: $password)
                    .frame(maxWidth: 300)
                    .textFieldStyle(.roundedBorder)
                Button("Set new password") {
                    defer { password = "" }
                    if MasterPasswordManager.deleteMasterPassword() {
                        print("Master password deleted")
                        if MasterPasswordManager.setMasterPassword(password) {
                            print("Master password successfully reset")
                            print("Logging out")
                            state = .loggedOut
                        } else {
                            print(
                                "Something went wrong while resetting the master password"
                            )
                        }
                    } else {
                        print(
                            "Something went wrong while reseting the master password"
                        )
                    }
                }
                .buttonStyle(.bordered)
                .tint(.mint)
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

                SecureField("Master password", text: $password)
                    .frame(maxWidth: 300)
                    .textFieldStyle(.roundedBorder)

                Button(buttonText) {
                    defer { password = "" }
                    if hasPassword {
                        if MasterPasswordManager.verifyMasterPassword(password) {
                            print("Master password accepted")
                            state = .loggedIn
                        } else {
                            print("Master password is incorrect")
                            alertMessage = "Wrong password"
                            showAlert = true
                        }
                    } else {
                        if MasterPasswordManager.setMasterPassword(password) {
                            print("Master password successfully set")
                            state = .loggedIn
                        } else {
                            print(
                                "Something went wrong while setting the master password"
                            )
                        }
                    }
                }
                .buttonStyle(.bordered)
                .tint(.mint)
                .disabled(state != .loggedIn && password.isEmpty)
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
