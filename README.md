# password-vault

Simple iOS and macOS password vault with components in both Swift and Objective-C to gain a better understanding of both languages.

## Features

- Secure vault password: Apple Keychain integration for vault password storage (Swift)
- Password validation: vault password strength verification (Objective-C)
- CRUD: create, read, update and delete password entries (Objective-C)
- Encrypted storage: AES-256 encryption for vault files at rest (Swift)
- Clean and simple UI (SwiftUI)

## Requirements

- iOS 26.0+
- macOS 15.6+
- Xcode 26.0.1+

## Preview

<p align="center">
  <img src="images/login-view.png" width="400" />
  <img src="images/main-view-empty.png" width="400" />
  <img src="images/main-view-sheet.png" width="400" />
  <img src="images/main-view-non-empty.png" width="400" />
  <img src="images/main-view-non-empty-edit.png" width="400" />
  <img src="images/main-view-non-empty-delete.png" width="400" />
</p>

## Command cheatsheet

### Build

```
$ xcodebuild build -scheme password-vault -derivedDataPath build -destination 'platform=iOS Simulator,arch=arm64,name=iPhone 17' -quiet
```

### Run

```
$ xcrun simctl boot "iPhone 17"
$ open -a Simulator
$ xcrun simctl install "iPhone 17" build/Build/Products/Debug-iphonesimulator/password-vault.app
$ xcrun simctl launch "iPhone 17" gemesa.password-vault
```

### Terminate

```
$ xcrun simctl terminate "iPhone 17" gemesa.password-vault
```

### Format Swift

```
$ brew install swift-format
$ swift-format -i -r password-vault/
```

Alternatively, use `Editor` --> `Structure` --> `Format File with 'swift-format'` or `Ctrl + Shift + I`.

### Lint Swift

```
$ brew install swiftlint
$ swiftlint --strict password-vault/
```

### Format Objective-C

```
$ find password-vault/ -name "*.m" -o -name "*.h" | xargs clang-format -i
```

Alternatively, use `Editor` --> `Structure` --> `Format File with 'clang-format'` or `Ctrl + Shift + I`.

### Analyze Objective-C

```
$ xcodebuild analyze -scheme password-vault -destination 'platform=iOS Simulator,name=iPhone 17' -quiet GCC_TREAT_WARNINGS_AS_ERRORS=YES
```

### Decryptor

A standalone command-line tool for decrypting vault files. Use this for:

- Debugging vault encryption issues
- Emergency access when the main app is unavailable
- Verifying vault integrity

```
$ cd decryptor
$ swiftc main.swift ../password-vault/Services/VaultEncryption.swift PasswordEntry.swift -o decrypt
$ ./decrypt
Usage: ./decrypt <vault_file_path> <password>
$ ./decrypt $(find ~/Library/Developer/CoreSimulator/Devices -name "vault.dat") secure1
Decrypted 518 bytes

Decrypted 1 password entries:

[1]
PasswordEntry:
  ID: 78B14FBD-2179-470A-8CD7-476EC5FD33D8
  Title: GitHub
  Username: GH_username
  Password: password1
  Notes: none
--------------------------------------------------
```
