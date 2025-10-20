# password-vault

Simple iOS and macOS password vault.

## Features

- Apple Keychain integration for managing the vault password

## TODO

- Stored password management

## Requirements

- iOS 26.0+
- macOS 15.6+
- Xcode 26.0.1+

## Preview

<p align="center">
  <img src="images/login-view.png" width="400" />
  <img src="images/main-view.png" width="400" />
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

### Lint Objective-C

```
$ xcodebuild analyze -scheme password-vault -destination 'platform=iOS Simulator,name=iPhone 17' -quiet GCC_TREAT_WARNINGS_AS_ERRORS=YES
```
