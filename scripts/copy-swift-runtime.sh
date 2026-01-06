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

# Architecture mappings
declare -A ARCH_MAP=(
    ["arm64-v8a"]="aarch64-unknown-linux-android"
    ["x86_64"]="x86_64-unknown-linux-android"
)

# Required Swift runtime libraries
RUNTIME_LIBS=(
    "libswiftCore.so"
    "libswiftGlibc.so"
    "libdispatch.so"
    "libBlocksRuntime.so"
    "libswiftSwiftOnoneSupport.so"
    "libswift_Concurrency.so"
)

for ABI in "${!ARCH_MAP[@]}"; do
    ARCH="${ARCH_MAP[$ABI]}"
    
    echo ""
    echo "📦 Copying runtime libraries for $ABI ($ARCH)..."
    
    # Find the lib directory for this architecture
    LIB_DIR=$(find "$SWIFT_SDK_PATH" -path "*$ARCH*" -name "lib" -type d | head -1)
    
    if [ -z "$LIB_DIR" ]; then
        echo "   ⚠️  Could not find lib directory for $ARCH"
        continue
    fi
    
    mkdir -p "$OUTPUT_DIR/$ABI"
    
    for LIB in "${RUNTIME_LIBS[@]}"; do
        LIB_PATH=$(find "$LIB_DIR" -name "$LIB" | head -1)
        if [ -n "$LIB_PATH" ] && [ -f "$LIB_PATH" ]; then
            cp "$LIB_PATH" "$OUTPUT_DIR/$ABI/"
            echo "   ✅ $LIB"
        else
            echo "   ⚠️  $LIB not found (may not be required)"
        fi
    done
done

echo ""
echo "✅ Runtime library copy complete!"
