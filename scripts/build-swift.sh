#!/bin/bash
set -e

# Swift Android Build Script
# This script builds the Swift library for Android architectures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SWIFT_LIB_DIR="$PROJECT_ROOT/swift-library"
OUTPUT_DIR="$PROJECT_ROOT/app/src/main/jniLibs"

# Android architectures to build for
ARCHS=("aarch64-unknown-linux-android28" "x86_64-unknown-linux-android28")
ABI_DIRS=("arm64-v8a" "x86_64")

echo "🔨 Building Swift library for Android..."
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
    echo "📦 Building for $ARCH ($ABI)..."
    
    # Build the Swift library
    swift build \
        --swift-sdk "$ARCH" \
        --static-swift-stdlib \
        -c release
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR/$ABI"
    
    # Find and copy the built library
    BUILD_DIR="$SWIFT_LIB_DIR/.build/release"
    if [ -f "$BUILD_DIR/libSwiftAndroidLib.so" ]; then
        cp "$BUILD_DIR/libSwiftAndroidLib.so" "$OUTPUT_DIR/$ABI/"
        echo "   ✅ Copied libSwiftAndroidLib.so to $ABI"
    else
        # Try architecture-specific build directory
        BUILD_DIR="$SWIFT_LIB_DIR/.build/$ARCH/release"
        if [ -f "$BUILD_DIR/libSwiftAndroidLib.so" ]; then
            cp "$BUILD_DIR/libSwiftAndroidLib.so" "$OUTPUT_DIR/$ABI/"
            echo "   ✅ Copied libSwiftAndroidLib.so to $ABI"
        else
            echo "   ❌ Could not find libSwiftAndroidLib.so"
            echo "   Searched in: $SWIFT_LIB_DIR/.build/release"
            echo "             and: $BUILD_DIR"
            exit 1
        fi
    fi
done

echo ""
echo "✅ Swift library build complete!"
echo ""
echo "📁 Output structure:"
find "$OUTPUT_DIR" -name "*.so" -exec ls -lh {} \;
