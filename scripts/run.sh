#!/bin/bash
set -e

# Quick run script - builds Swift, assembles APK, installs and launches
# Usage: ./scripts/run.sh [--release]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
PACKAGE="com.example.swiftandroid"

cd "$PROJECT_ROOT"

# Check for release flag
BUILD_TYPE="debug"
GRADLE_TASK="assembleDebug"
APK_PATH="app/build/outputs/apk/debug/app-debug.apk"

if [ "$1" = "--release" ] || [ "$1" = "-r" ]; then
    BUILD_TYPE="release"
    GRADLE_TASK="assembleRelease"
    APK_PATH="app/build/outputs/apk/release/app-release.apk"
fi

# Check emulator is running
if ! "$ADB" devices 2>/dev/null | grep -q "device$"; then
    echo "❌ No device/emulator connected!"
    echo "   Run: ./scripts/emulator.sh start"
    exit 1
fi

echo "🔨 Building Swift library..."
./scripts/build-swift.sh $([ "$BUILD_TYPE" = "release" ] && echo "--release") 2>&1 | grep -E "(✅|❌|Build complete|error:)" || true

echo ""
echo "📦 Building Android APK ($BUILD_TYPE)..."
./gradlew "$GRADLE_TASK" --quiet

echo ""
echo "📲 Installing APK..."
"$ADB" install -r "$APK_PATH"

echo ""
echo "🚀 Launching app..."
"$ADB" shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1

echo ""
echo "✅ App running! Use './scripts/run.sh logcat' to see logs"
echo ""

# If logcat argument, show logs
if [ "$1" = "logcat" ] || [ "$2" = "logcat" ]; then
    echo "📋 Showing logs (Ctrl+C to stop)..."
    "$ADB" logcat -v time | grep -iE "(swift|python|System.out|AndroidExample|$PACKAGE)"
fi
