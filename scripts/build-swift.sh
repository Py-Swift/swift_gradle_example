#!/bin/bash
set -e

# Swift Android Build Script
# This script builds the Swift library for Android architectures
# Includes swift-java support for calling Java libraries from Swift
#
# Usage: ./build-swift.sh [--release]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SWIFT_LIB_DIR="$PROJECT_ROOT/swift-library"
OUTPUT_DIR="$PROJECT_ROOT/app/src/main/jniLibs"

# Build configuration (debug by default, use --release for release)
BUILD_CONFIG="debug"
if [ "$1" = "--release" ] || [ "$1" = "-r" ]; then
    BUILD_CONFIG="release"
fi

# Android architectures to build for
# Building both arm64-v8a (real devices) and x86_64 (emulators)
ARCHS=("aarch64-unknown-linux-android28" "x86_64-unknown-linux-android28")
ABI_DIRS=("arm64-v8a" "x86_64")

# For faster builds during development, uncomment to only build arm64:
# ARCHS=("aarch64-unknown-linux-android28")
# ABI_DIRS=("arm64-v8a")

echo "🔨 Building Swift library for Android ($BUILD_CONFIG)..."
echo "   Swift library: $SWIFT_LIB_DIR"
echo "   Output: $OUTPUT_DIR"

# Check if swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift not found. Please install Swift toolchain."
    exit 1
fi

# Check if Android SDK is installed
if ! swift sdk list 2>/dev/null | grep -q "android"; then
    echo "⚠️  Swift SDK for Android not found."
    echo "   Install it with:"
    echo "   swift sdk install <android-sdk-url>"
    echo ""
    echo "   See: https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html"
    exit 1
fi

cd "$SWIFT_LIB_DIR"

for i in "${!ARCHS[@]}"; do
    ARCH="${ARCHS[$i]}"
    ABI="${ABI_DIRS[$i]}"
    
    echo ""
    echo "📦 Building for $ARCH ($ABI) [$BUILD_CONFIG]..."
    
    # Path to libpython3.13.so for linking
    PYTHON_LIB_DIR="$OUTPUT_DIR/$ABI"
    
    # Build the Swift library (includes swift-java dependency)
    # --disable-sandbox is required for SwiftJavaPlugin to fetch Java dependencies
    # -Xlinker -L adds library search path for libpython3.13.so
    swift build \
        --swift-sdk "$ARCH" \
        --disable-sandbox \
        -c "$BUILD_CONFIG" \
        -Xlinker -L"$PYTHON_LIB_DIR"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR/$ABI"
    
    # Find the build directory - try architecture-specific first
    BUILD_DIR="$SWIFT_LIB_DIR/.build/$ARCH/$BUILD_CONFIG"
    if [ ! -d "$BUILD_DIR" ]; then
        BUILD_DIR="$SWIFT_LIB_DIR/.build/$BUILD_CONFIG"
    fi
    
    echo "   📁 Build directory: $BUILD_DIR"
    
    # Copy libSwiftAndroidLib.so (our main library)
    if [ -f "$BUILD_DIR/libSwiftAndroidLib.so" ]; then
        cp "$BUILD_DIR/libSwiftAndroidLib.so" "$OUTPUT_DIR/$ABI/"
        echo "   ✅ Copied libSwiftAndroidLib.so"
    else
        echo "   ❌ Could not find libSwiftAndroidLib.so in $BUILD_DIR"
        ls -la "$BUILD_DIR"/*.so 2>/dev/null || echo "   No .so files found"
        exit 1
    fi
    
    # Copy libSwiftJava.so (swift-java runtime for JNI interop)
    if [ -f "$BUILD_DIR/libSwiftJava.so" ]; then
        cp "$BUILD_DIR/libSwiftJava.so" "$OUTPUT_DIR/$ABI/"
        echo "   ✅ Copied libSwiftJava.so (swift-java runtime)"
    else
        echo "   ⚠️  libSwiftJava.so not found (may not be needed if not using swift-java)"
    fi
    
    # Copy any other built libraries (like JavaCSV wrapper if built separately)
    for lib in "$BUILD_DIR"/lib*.so; do
        if [ -f "$lib" ]; then
            LIB_NAME=$(basename "$lib")
            if [ "$LIB_NAME" != "libSwiftAndroidLib.so" ] && [ "$LIB_NAME" != "libSwiftJava.so" ]; then
                cp "$lib" "$OUTPUT_DIR/$ABI/"
                echo "   ✅ Copied $LIB_NAME"
            fi
        fi
    done
done

echo ""
echo "✅ Swift library build complete!"
echo ""
echo "📁 Output structure:"
find "$OUTPUT_DIR" -name "*.so" -exec ls -lh {} \;

echo ""
echo "📝 Next steps:"
echo "   1. Run: ./scripts/copy-swift-runtime.sh"
echo "   2. Build the Android app: ./gradlew assembleDebug"
echo "   3. Install on device: adb install -r app/build/outputs/apk/debug/app-debug.apk"
