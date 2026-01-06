# Python on Android with Swift Integration

## Overview

This document covers the work done to integrate Python (CPython) with Swift on Android, the challenges encountered, solutions found, and remaining TODOs.

**Goal:** Complete the chain `Kotlin/Java ↔ Swift ↔ Python` using PySwiftKit/CPython.

---

## ✅ What Works

### 1. Building Python 3.13 for Android

Python can be cross-compiled for Android using the official Python build scripts.

```bash
# Clone Python source
git clone https://github.com/python/cpython.git
cd cpython
git checkout v3.13.1

# Build for Android (requires Android NDK)
export ANDROID_HOME=~/Library/Android/sdk

# Build for arm64 (real devices)
./Android/android.py build --sdk-version 28 aarch64-linux-android

# Build for x86_64 (emulators)  
./Android/android.py build --sdk-version 28 x86_64-linux-android
```

**Output locations:**
- `cross-build/aarch64-linux-android/build/libpython3.13.so` (~25MB)
- `cross-build/x86_64-linux-android/build/libpython3.13.so` (~25MB)
- `cross-build/*/build/lib/python3.13/` - Standard library

### 2. Linking libpython3.13.so with Swift on Android

**Key insight:** Swift Package Manager for Android can link against `.so` files placed in `jniLibs`.

The solution was to:
1. Copy `libpython3.13.so` to `app/src/main/jniLibs/arm64-v8a/` and `x86_64/`
2. Use `.linkedLibrary("python3.13")` in Package.swift
3. SPM finds the library at link time via the Android SDK's library search paths

**Package.swift example:**
```swift
.target(
    name: "CPython",
    sources: ["CPython.c"],
    publicHeadersPath: "include",
    cSettings: [
        .define("PY_SSIZE_T_CLEAN"),
        .headerSearchPath("../../PythonHeaders"),
    ],
    linkerSettings: [
        .linkedLibrary("python3.13"),
    ]
)
```

### 3. Python Headers Location

Python headers must be available at compile time. We copied them to `CPython-android/PythonHeaders/` (outside of `Sources/` to avoid SPM issues).

Headers come from: `cross-build/*/build/include/python3.13/`

### 4. Python Standard Library on Android

The stdlib must be copied to the app's assets and extracted at runtime:
- Source: `cross-build/*/build/lib/python3.13/`
- Destination in APK: `assets/python3.13/`
- Runtime extraction: `files/python3.13/`

---

## ❌ Current Problems

### 1. CPython Wrapper Hides Python API from Swift

**Problem:** To avoid Swift module compilation errors with Python.h (complex macros, implicit int, etc.), we created a minimal C wrapper (`CPython.h`) that hides Python.h from Swift.

```c
// CPython.h - Only these functions exposed to Swift
int CPython_Initialize(const char* pythonHome);
void CPython_Finalize(void);
int CPython_IsInitialized(void);
int CPython_RunString(const char* code);
const char* CPython_GetVersion(void);
```

**Consequence:** PySwiftKit and other Swift packages that need direct access to Python's C API (`PyObject*`, `PyDict_*`, etc.) cannot work with this approach.

### 2. Python Home Path Not Working

The `PyConfig.home` setting isn't finding the stdlib. Need to investigate:
- Correct path structure expected by Python
- Whether `PYTHONPATH` environment variable is needed
- Android-specific initialization requirements

### 3. No Framework Support (Unlike macOS/iOS)

On macOS/iOS, Python is typically linked as a framework:
```swift
.linkedFramework("Python")
```

On Android, we use:
```swift
.linkedLibrary("python3.13")
```

This inconsistency means cross-platform Swift packages need conditional compilation.

---

## 📋 TODO List

### Short Term

- [ ] Fix Python initialization on Android (stdlib path issue)
- [ ] Test `PyRun_SimpleString` actually executes Python code
- [ ] Add proper error handling and logging to CPython wrapper

### Medium Term (PySwiftKit Compatibility)

- [ ] Research how to expose Python.h to Swift without compilation errors
  - Option A: Use Swift's `@_implementationOnly import` to hide internal headers
  - Option B: Create Swift-compatible header subset
  - Option C: Use module.modulemap to control what's exposed
- [ ] Create a `CPython` Swift module that can be shared between our code and PySwiftKit
- [ ] Ensure `PyObject*` and other Python types are accessible from Swift

### Long Term (Cross-Platform)

- [ ] Unify the linking approach for Android (.so) and macOS/iOS (.framework)
- [ ] Create a single Package.swift that works on all platforms:
  ```swift
  #if os(Android)
  .linkedLibrary("python3.13")
  #else
  .linkedFramework("Python")
  #endif
  ```
- [ ] Investigate using XCFramework for cross-platform Python distribution
- [ ] Consider contributing Android support to PySwiftKit upstream

---

## File Locations

```
swift_gradle_example/
├── CPython-android/                    # CPython Swift package wrapper
│   ├── Package.swift                   # Package definition
│   ├── PythonHeaders/                  # Python 3.13 headers (81 files)
│   │   ├── Python.h
│   │   ├── pyconfig.h
│   │   └── ...
│   └── Sources/CPython/
│       ├── include/
│       │   └── CPython.h               # Minimal public header for Swift
│       └── CPython.c                   # Implementation using Python.h
│
├── app/src/main/
│   ├── jniLibs/
│   │   ├── arm64-v8a/
│   │   │   └── libpython3.13.so        # Python runtime (~25MB)
│   │   └── x86_64/
│   │       └── libpython3.13.so
│   └── assets/
│       └── python3.13/                 # Python stdlib
│
└── swift-library/
    ├── Package.swift                   # Depends on CPython
    └── Sources/SwiftAndroidLib/
        └── SwiftAndroidLib.swift       # Python integration code
```

---

## References

- [Python for Android Official Docs](https://docs.python.org/3/using/android.html)
- [PySwiftKit](https://github.com/pyskit/PySwiftKit) - Swift-Python interop (macOS/iOS)
- [CPython Package](https://github.com/Py-Swift/CPython) - CPython headers for Swift
- [Swift SDK for Android](https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html)

---

## Build Commands Reference

```bash
# Build Python for Android
cd cpython
./Android/android.py build --sdk-version 28 aarch64-linux-android
./Android/android.py build --sdk-version 28 x86_64-linux-android

# Copy libpython to jniLibs
cp cross-build/aarch64-linux-android/build/libpython3.13.so \
   ../swift_gradle_example/app/src/main/jniLibs/arm64-v8a/
cp cross-build/x86_64-linux-android/build/libpython3.13.so \
   ../swift_gradle_example/app/src/main/jniLibs/x86_64/

# Copy Python headers
cp -r cross-build/aarch64-linux-android/build/include/python3.13/* \
   ../swift_gradle_example/CPython-android/PythonHeaders/

# Copy Python stdlib to assets
cp -r cross-build/aarch64-linux-android/build/lib/python3.13/* \
   ../swift_gradle_example/app/src/main/assets/python3.13/

# Build Swift for Android
cd swift_gradle_example
./scripts/build-swift.sh

# Build Android APK
./gradlew assembleDebug

# Install and run
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n com.example.swiftandroid/.MainActivity
```

---

*Last updated: January 6, 2026*
