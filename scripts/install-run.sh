#!/bin/bash
# Install and run the app on emulator

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
APK="$PROJECT_DIR/app/build/outputs/apk/debug/app-debug.apk"
PACKAGE="com.example.swiftandroid"

cd "$PROJECT_DIR"

# Check if APK exists
if [ ! -f "$APK" ]; then
    echo "❌ APK not found. Run './gradlew assembleDebug' first"
    exit 1
fi

# Install
echo "📦 Installing app..."
$ADB install -r "$APK"

# Launch
echo "🚀 Launching app..."
$ADB shell am start -n "$PACKAGE/.MainActivity"

echo "✅ Done!"
