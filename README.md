# Swift Android Example

A demonstration project showing Swift code running on Android via the Swift SDK for Android, with JNI bridging to Kotlin/Compose UI.

## Project Structure

```
swift_gradle_example/
├── app/                          # Android app module
│   ├── build.gradle.kts
│   └── src/main/
│       ├── java/com/example/swiftandroid/
│       │   ├── MainActivity.kt   # Compose UI
│       │   └── SwiftBridge.kt    # JNI bridge
│       └── jniLibs/              # Native libraries (built)
├── swift-library/                # Swift library
│   ├── Package.swift
│   └── Sources/SwiftAndroidLib/
│       └── SwiftAndroidLib.swift # Swift JNI implementation
├── scripts/
│   ├── setup-android-sdk.sh      # One-time setup
│   ├── build-swift.sh            # Build Swift for Android
│   └── copy-swift-runtime.sh     # Copy Swift runtime libs
├── build.gradle.kts              # Root Gradle config
└── settings.gradle.kts
```

## Prerequisites

1. **Swift Toolchain** (nightly snapshot matching the Android SDK)
   ```bash
   # Install swiftly: https://www.swift.org/swiftly/
   swiftly install main-snapshot-2025-12-17
   swiftly use main-snapshot-2025-12-17
   ```

2. **Swift SDK for Android**
   ```bash
   swift sdk install https://download.swift.org/development/android-sdk/swift-DEVELOPMENT-SNAPSHOT-2025-12-17-a/swift-DEVELOPMENT-SNAPSHOT-2025-12-17-a_android.artifactbundle.tar.gz
   ```

3. **Android NDK r27d**
   ```bash
   mkdir ~/android-ndk && cd ~/android-ndk
   curl -fSLO https://dl.google.com/android/repository/android-ndk-r27d-darwin.zip
   unzip android-ndk-r27d-darwin.zip
   export ANDROID_NDK_HOME=$PWD/android-ndk-r27d
   ```

4. **Link NDK to Swift SDK**
   ```bash
   cd ~/Library/org.swift.swiftpm/swift-sdks/swift-*android*/swift-android/scripts
   ./setup-android-sdk.sh
   ```

## Building

### 1. Setup (one time)
```bash
./scripts/setup-android-sdk.sh
```

### 2. Build Swift Library
```bash
./scripts/build-swift.sh
```

### 3. Copy Swift Runtime (if not using static stdlib)
```bash
./scripts/copy-swift-runtime.sh
```

### 4. Build Android App
```bash
./gradlew assembleDebug
```

Or open in Android Studio and run.

## How It Works

1. **Swift Library** ([swift-library/Sources/SwiftAndroidLib/SwiftAndroidLib.swift](swift-library/Sources/SwiftAndroidLib/SwiftAndroidLib.swift))
   - Compiled for Android using Swift SDK
   - Exports JNI-compatible functions using `@_cdecl`
   - Returns strings to Java/Kotlin

2. **JNI Bridge** ([app/src/main/java/com/example/swiftandroid/SwiftBridge.kt](app/src/main/java/com/example/swiftandroid/SwiftBridge.kt))
   - Loads Swift runtime libraries
   - Declares `external` native methods
   - Bridges Kotlin to Swift

3. **Compose UI** ([app/src/main/java/com/example/swiftandroid/MainActivity.kt](app/src/main/java/com/example/swiftandroid/MainActivity.kt))
   - Displays text from Swift
   - Standard Android Jetpack Compose

## Next Steps (See plan.md)

- **Phase 2**: Add swift-java for richer Java interop
- **Phase 3**: Integrate PySwiftKit for Python support

## References

- [Swift SDK for Android Getting Started](https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html)
- [swift-android-examples](https://github.com/swiftlang/swift-android-examples)
- [swift-java](https://github.com/swiftlang/swift-java)
