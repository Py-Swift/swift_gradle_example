#!/bin/bash
set -e

# Setup Swift SDK for Android
# Run this script once to set up the development environment

echo "🛠️  Swift SDK for Android Setup"
echo "================================"
echo ""

# Check for swiftly
if command -v swiftly &> /dev/null; then
    echo "✅ swiftly found"
else
    echo "⚠️  swiftly not found. Install it from: https://www.swift.org/swiftly/"
    echo "   Or install Swift manually from: https://www.swift.org/download/"
fi

# Check Swift version
if command -v swift &> /dev/null; then
    SWIFT_VERSION=$(swift --version | head -1)
    echo "✅ Swift: $SWIFT_VERSION"
else
    echo "❌ Swift not found"
    exit 1
fi

# Check for Android NDK
if [ -n "$ANDROID_NDK_HOME" ]; then
    echo "✅ ANDROID_NDK_HOME: $ANDROID_NDK_HOME"
else
    echo "⚠️  ANDROID_NDK_HOME not set"
    echo "   Download NDK r27d from: https://developer.android.com/ndk/downloads"
fi

# List installed Swift SDKs
echo ""
echo "📋 Installed Swift SDKs:"
swift sdk list 2>/dev/null || echo "   (none or swift sdk command not available)"

echo ""
echo "📝 To install Swift SDK for Android:"
echo ""
echo "1. Install a nightly Swift snapshot that matches the SDK:"
echo "   swiftly install main-snapshot-2025-12-17"
echo "   swiftly use main-snapshot-2025-12-17"
echo ""
echo "2. Install the Android SDK:"
echo "   swift sdk install https://download.swift.org/development/android-sdk/swift-DEVELOPMENT-SNAPSHOT-2025-12-17-a/swift-DEVELOPMENT-SNAPSHOT-2025-12-17-a_android.artifactbundle.tar.gz"
echo ""
echo "3. Download and configure Android NDK r27d:"
echo "   mkdir ~/android-ndk && cd ~/android-ndk"
echo "   curl -fSLO https://dl.google.com/android/repository/android-ndk-r27d-darwin.zip"
echo "   unzip android-ndk-r27d-darwin.zip"
echo "   export ANDROID_NDK_HOME=\$PWD/android-ndk-r27d"
echo ""
echo "4. Link NDK to Swift SDK (run the setup script from the SDK):"
echo "   cd ~/Library/org.swift.swiftpm/swift-sdks/swift-*android*/swift-android/scripts"
echo "   ./setup-android-sdk.sh"
echo ""
echo "For more details, see:"
echo "https://www.swift.org/documentation/articles/swift-sdk-for-android-getting-started.html"
