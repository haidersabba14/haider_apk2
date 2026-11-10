# Haider APK Emulator 📱

A bilingual-ready, Arabic-first SwiftUI iPhone/iPad APK **library and inspector**.

> ⚠️ **Important:** This MVP does **not** run Android apps. iOS cannot execute APK
> files natively. An Android runtime/emulator is not included. The app imports,
> validates, previews, shares and deletes APK files. See [runtime research](docs/ANDROID_RUNTIME.md).

## Features

- 📂 Import `.apk` files from the iOS Files app.
- 🔎 Validate ZIP contents (manifest + DEX) and inspect a file preview.
- 🧩 Show embedded Android native library architectures (ABIs).
- 💾 Keep the APKs locally with persistent metadata.
- 🔄 Share and delete files.
- 🎨 Dark navy, cyan and violet SwiftUI interface with an auto-generated app icon.
- 🧱 GitHub Actions produces a downloadable **unsigned** IPA on every push to `main`.

## Get the IPA using GitHub (no Mac required to build)

1. Open this repository's **Actions** tab.
2. Choose **Build Haider APK IPA**.
3. Click **Run workflow** (or open the run started by a push).
4. After a successful build, open **Artifacts → HaiderAPK-unsigned-IPA**.
5. Download the ZIP, extract it, and find `HaiderAPK-unsigned.ipa`.

The GitHub build produces an **unsigned** IPA, which is **not directly installable**
on a normal iPhone. Sign the IPA with valid iOS credentials and a compatible
installation method. Signing is not bypassed by changing the file extension.

## Local build using a Mac

```bash
brew install xcodegen
swift Scripts/create-icon.swift
xcodegen generate
open HaiderAPK.xcodeproj
```

Set your signing team in Xcode, then build to a device or archive/export.

## Technology

- SwiftUI (iOS 16+, iPhone and iPad)
- ZIPFoundation 0.9.20+ for inspecting ZIP-based APK contents
- XcodeGen to generate the Xcode project
- GitHub Actions on macOS to compile and package the IPA

## Scope and limitations

Importing APKs is **not installing Android apps**. This project does not promise
Oscar TV compatibility or Android execution, including on jailbroken devices.
The code contains no misleading fake Run button.

The next engineering milestone is validating the feasibility of a genuine
Android guest runtime under stock iOS's execution, entitlement and performance limits.
