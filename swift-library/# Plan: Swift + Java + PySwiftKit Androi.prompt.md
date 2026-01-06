# Plan: Swift + Java + PySwiftKit Android Integration

This plan covers building an Android app stack combining Swift (via Android SDK), Java interop (swift-java), and Python support (PySwiftKit). Each phase builds on the previous, with Phase 3 requiring the most adaptation work due to lack of existing Android support in Py-Swift packages.

---

## Phase 1: Gradle + Swift App Setup

1. **Install toolchain** — Use `swiftly` to install matching nightly Swift snapshot (6.3-dev) and Android SDK (must match versions exactly)
2. **Configure NDK r27d** — Download and link via provided `setup-android-sdk.sh` script in the SDK bundle
3. **Create Swift library** — Build a dynamic `.library` target with `--swift-sdk aarch64-unknown-linux-android28 --static-swift-stdlib`
4. **Setup Android app** — Follow [hello-swift-java](https://github.com/swiftlang/swift-android-examples/tree/main/hello-swift-java) example for Gradle + JNI loading structure
5. **Wire Swift to UI** — Expose Swift function returning text string, call from Kotlin Compose via JNI bindings

---

## Phase 2: Swift-Java Interop (CSV Sample)

1. **Configure swift-java.config** — Define Maven dependencies (e.g., `org.apache.commons:commons-csv:1.10.0`) and class mappings following [JavaCommonsCSV sample](https://github.com/swiftlang/swift-java/tree/main/Samples/JavaDependencySampleApp/Sources/JavaCommonsCSV)
2. **Setup Package.swift** — Add `swift-java` dependency with `SwiftJavaPlugin` for wrapper generation, use JNI mode (not FFM) for Android compatibility
3. **Implement Swift code** — Use generated Swift wrappers to call Java CSV parsing: `JavaClass<CSVFormat>().RFC4180.parse(...)`
4. **Handle classpath** — Bundle resolved Maven JARs in APK, use `System.loadLibrary()` from Java side

---

## Phase 3: CPython + PySwiftKit for Android

**The grand goal: PySwiftKit running on Android via a modified CPython package.**

### Dependency Chain

```
Android Python Build (libpython3.13.so)
         ↓
Py-Swift/CPython (forked/modified to link Android build)
         ↓
PySwiftKit (depends on CPython package)
         ↓
Your Swift Android App
```

### Steps

1. **Build Python 3.13 for Android** — Use official [CPython Android build](https://github.com/python/cpython/tree/main/Android) to produce `libpython3.13.so` + headers for arm64/x86_64
2. **Fork & modify Py-Swift/CPython** — This is the critical adaptation layer:
   - Replace iOS xcframework with Android `.so` binaries
   - Update module map and linking flags to point to Android Python build
   - All Python runtime/launching goes through this package
3. **PySwiftKit works automatically** — Once CPython package correctly exposes Android Python, PySwiftKit should compile against it with minimal changes (platform guards for Android)
4. **Bundle Python stdlib** — Package in APK assets, extract before `Py_Initialize()` per [Android Python docs](https://docs.python.org/3/using/android.html)
5. **Integrate full stack** — Kotlin → JNI → Swift → PySwiftKit → Python runtime
   - Java does NOT touch Python API directly
   - Java only ensures Swift runtime/library startup
   - All Python interaction flows through Swift via PySwiftKit

---

## Key Considerations

1. **Version pinning critical** — Swift SDK snapshot must exactly match host toolchain; pin swift-java to specific commit. Use `swiftly` for toolchain management.
2. **CPython package is the linchpin** — All effort focuses on making Py-Swift/CPython link correctly with Android Python; PySwiftKit's functionality follows from this.
3. **Binary size** — Full Python runtime adds ~30MB; consider APK splits or on-demand download for release builds.

---

## References

- https://www.swift.org/blog/nightly-swift-sdk-for-android/
- https://github.com/swiftlang/swift-java
- https://github.com/swiftlang/swift-android-examples
- https://github.com/Py-Swift/CPython
- https://github.com/Py-Swift/PySwiftKit
- https://github.com/python/cpython/tree/main/Android
