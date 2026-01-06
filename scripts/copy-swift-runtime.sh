#!/bin/bash
set -e

# Copy Swift Runtime Libraries Script
# This script copies required Swift runtime libraries to the Android jniLibs folder
# Required for swift-java and Swift standard library support on Android

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/app/src/main/jniLibs"

# Try to find the Swift SDK location
SWIFT_SDK_PATH=""

# Check common locations
if [ -d "$HOME/Library/org.swift.swiftpm/swift-sdks" ]; then
    # macOS location - find latest android SDK
    SWIFT_SDK_PATH=$(find "$HOME/Library/org.swift.swiftpm/swift-sdks" -maxdepth 1 -name "*android*" -type d | sort -V | tail -1)
elif [ -d "$HOME/.swiftpm/swift-sdks" ]; then
    # Linux location
    SWIFT_SDK_PATH=$(find "$HOME/.swiftpm/swift-sdks" -maxdepth 1 -name "*android*" -type d | sort -V | tail -1)
fi

if [ -z "$SWIFT_SDK_PATH" ]; then
    echo "❌ Could not find Swift SDK for Android"
    echo "   Please set SWIFT_SDK_PATH environment variable"
    exit 1
fi

echo "🔍 Found Swift SDK at: $SWIFT_SDK_PATH"

# Architecture mappings (avoiding associative arrays for bash 3.x compatibility)
# Building both arm64-v8a (real devices) and x86_64 (emulators)
ABIS="arm64-v8a x86_64"

# For faster builds during development, uncomment to only copy arm64:
# ABIS="arm64-v8a"

get_swift_arch_dir_for_abi() {
    case "$1" in
        "arm64-v8a") echo "swift-aarch64" ;;
        "x86_64") echo "swift-x86_64" ;;
    esac
}

# Copy ALL Swift runtime libraries to ensure all dependencies are met
for ABI in $ABIS; do
    ARCH_DIR=$(get_swift_arch_dir_for_abi "$ABI")
    
    echo ""
    echo "📦 Copying runtime libraries for $ABI..."
    
    # The SDK structure is: swift-sdk/swift-android/swift-resources/usr/lib/<arch>/android/
    LIB_DIR="$SWIFT_SDK_PATH/swift-android/swift-resources/usr/lib/$ARCH_DIR/android"
    
    if [ ! -d "$LIB_DIR" ]; then
        # Try alternate structure for older SDK
        LIB_DIR="$SWIFT_SDK_PATH/toolchains/*/usr/lib/swift/android"
        LIB_DIR=$(find "$SWIFT_SDK_PATH" -path "*/$ARCH_DIR/android" -type d 2>/dev/null | head -1)
    fi
    
    if [ -z "$LIB_DIR" ] || [ ! -d "$LIB_DIR" ]; then
        echo "   ⚠️  Could not find lib directory for $ABI"
        echo "   Searched: $SWIFT_SDK_PATH/swift-android/swift-resources/usr/lib/$ARCH_DIR/android"
        continue
    fi
    
    echo "   📁 Source: $LIB_DIR"
    
    mkdir -p "$OUTPUT_DIR/$ABI"
    
    # Copy all .so files from the Swift SDK lib directory
    COPIED=0
    for LIB_PATH in "$LIB_DIR"/*.so; do
        if [ -f "$LIB_PATH" ]; then
            LIB_NAME=$(basename "$LIB_PATH")
            cp "$LIB_PATH" "$OUTPUT_DIR/$ABI/"
            echo "   ✅ $LIB_NAME"
            COPIED=$((COPIED + 1))
        fi
    done
    
    if [ $COPIED -eq 0 ]; then
        echo "   ⚠️  No .so files found in $LIB_DIR"
    else
        echo "   📊 Copied $COPIED runtime libraries"
    fi
done

echo ""
echo "✅ Runtime library copy complete!"

# Copy libc++_shared.so from Android NDK if available
echo ""
echo "📦 Looking for libc++_shared.so from Android NDK..."

ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-$HOME/Library/Android/sdk/ndk}"

if [ -d "$ANDROID_NDK_HOME" ]; then
    # Find the latest NDK version
    NDK_VERSION=$(ls "$ANDROID_NDK_HOME" 2>/dev/null | sort -V | tail -1)
    
    if [ -n "$NDK_VERSION" ]; then
        NDK_PATH="$ANDROID_NDK_HOME/$NDK_VERSION"
        
        for ABI in $ABIS; do
            case "$ABI" in
                "arm64-v8a") NDK_ARCH="aarch64-linux-android" ;;
                "x86_64") NDK_ARCH="x86_64-linux-android" ;;
            esac
            
            # Try darwin first, then linux
            LIBCPP="$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/$NDK_ARCH/libc++_shared.so"
            if [ ! -f "$LIBCPP" ]; then
                LIBCPP="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/$NDK_ARCH/libc++_shared.so"
            fi
            
            if [ -f "$LIBCPP" ]; then
                cp "$LIBCPP" "$OUTPUT_DIR/$ABI/"
                echo "   ✅ libc++_shared.so copied for $ABI"
            else
                echo "   ⚠️  libc++_shared.so not found for $ABI"
            fi
        done
    else
        echo "   ⚠️  No NDK version found in $ANDROID_NDK_HOME"
    fi
else
    echo "   ⚠️  Android NDK not found at $ANDROID_NDK_HOME"
    echo "      Install via Android Studio or: sdkmanager 'ndk;27.0.12077973'"
fi

echo ""
echo "📁 Final jniLibs structure:"
find "$OUTPUT_DIR" -name "*.so" | head -20
TOTAL=$(find "$OUTPUT_DIR" -name "*.so" | wc -l | tr -d ' ')
echo "   Total: $TOTAL libraries"

echo ""
echo "📝 Next step: Build the Android app"
echo "   ./gradlew assembleDebug"
