# password-vault

Simple iOS and macOS password vault.

## Features

- Apple Keychain integration for managing the master password

## TODO

- Stored password management

## Requirements

- iOS 26.0+
- macos 15.6+
- Xcode 26.0.1+

## How to build

```
$ xcodebuild build -scheme password-vault -derivedDataPath build -destination 'platform=iOS Simulator,arch=arm64,name=iPhone 17' -quiet
```

## Preview

<p align="center">
  <img src="images/login-view.png" width="400" />
  <img src="images/main-view.png" width="400" />
</p>
