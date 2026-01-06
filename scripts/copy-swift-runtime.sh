#!/bin/bash
set -e

# Copy Swift Runtime Libraries Script
# This script copies required Swift runtime libraries to the Android jniLibs folder

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/app/src/main/jniLibs"

# Try to find the Swift SDK location
SWIFT_SDK_PATH=""

# Check common locations
if [ -d "$HOME/Library/org.swift.swiftpm/swift-sdks" ]; then
    # macOS location
    SWIFT_SDK_PATH=$(find "$HOME/Library/org.swift.swiftpm/swift-sdks" -name "*android*" -type d | head -1)
elif [ -d "$HOME/.swiftpm/swift-sdks" ]; then
    # Linux location
    SWIFT_SDK_PATH=$(find "$HOME/.swiftpm/swift-sdks" -name "*android*" -type d | head -1)
fi

if [ -z "$SWIFT_SDK_PATH" ]; then
    echo "❌ Could not find Swift SDK for Android"
    echo "   Please set SWIFT_SDK_PATH environment variable"
    exit 1
fi

echo "🔍 Found Swift SDK at: $SWIFT_SDK_PATH"

# Architecture mappings (avoiding associative arrays for bash 3.x compatibility)
ABIS="arm64-v8a x86_64"

get_swift_lib_dir_for_abi() {
    case "$1" in
        "arm64-v8a") echo "swift-aarch64" ;;
        "x86_64") echo "swift-x86_64" ;;
    esac
}

# Copy ALL Swift runtime libraries to ensure all dependencies are met
for ABI in $ABIS; do
    SWIFT_LIB_DIR=$(get_swift_lib_dir_for_abi "$ABI")
    
    echo ""
    echo "📦 Copying runtime libraries for $ABI..."
    
    # Find the lib directory for this architecture using the actual SDK structure
    LIB_DIR=$(find "$SWIFT_SDK_PATH" -type d -name "$SWIFT_LIB_DIR" | head -1)
    
    if [ -n "$LIB_DIR" ]; then
        # Look for android subdirectory
        if [ -d "$LIB_DIR/android" ]; then
            LIB_DIR="$LIB_DIR/android"
        fi
    fi
    
    if [ -z "$LIB_DIR" ]; then
        echo "   ⚠️  Could not find lib directory for $ABI"
        continue
    fi
    
    mkdir -p "$OUTPUT_DIR/$ABI"
    
    # Copy all .so files from the Swift SDK lib directory
    for LIB_PATH in "$LIB_DIR"/*.so; do
        if [ -f "$LIB_PATH" ]; then
            LIB_NAME=$(basename "$LIB_PATH")
            cp "$LIB_PATH" "$OUTPUT_DIR/$ABI/"
            echo "   ✅ $LIB_NAME"
        fi
    done
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
            
            LIBCPP="$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/$NDK_ARCH/libc++_shared.so"
            
            if [ -f "$LIBCPP" ]; then
                cp "$LIBCPP" "$OUTPUT_DIR/$ABI/"
                echo "   ✅ libc++_shared.so copied for $ABI"
            else
                echo "   ⚠️  libc++_shared.so not found for $ABI at: $LIBCPP"
            fi
        done
    else
        echo "   ⚠️  No NDK version found in $ANDROID_NDK_HOME"
    fi
else
    echo "   ⚠️  Android NDK not found. Please install it via Android Studio or sdkmanager."
    echo "      Run: sdkmanager 'ndk;26.1.10909125'"
fi
