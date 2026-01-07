#!/bin/bash

# Android Emulator Script
# Usage: ./emulator.sh [start|stop|status|list]

ANDROID_SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
EMULATOR="$ANDROID_SDK/emulator/emulator"
ADB="$ANDROID_SDK/platform-tools/adb"

# Default AVD (first available if not set)
DEFAULT_AVD="Pixel_9a"

show_help() {
    echo "Android Emulator Management Script"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  start [avd]    Start emulator (default: $DEFAULT_AVD)"
    echo "  stop           Stop running emulator"
    echo "  status         Show emulator status"
    echo "  list           List available AVDs"
    echo "  install        Install APK to emulator"
    echo "  logcat         Show Android logs (filtered for Swift)"
    echo ""
    echo "Examples:"
    echo "  $0 start              # Start default emulator"
    echo "  $0 start Pixel_9a     # Start specific AVD"
    echo "  $0 install            # Install debug APK"
    echo "  $0 logcat             # View Swift/app logs"
}

list_avds() {
    echo "📱 Available Android Virtual Devices:"
    "$EMULATOR" -list-avds
}

start_emulator() {
    local avd="${1:-$DEFAULT_AVD}"
    
    # Check if emulator is already running
    if "$ADB" devices | grep -q "emulator"; then
        echo "⚠️  Emulator already running"
        "$ADB" devices
        return 0
    fi
    
    echo "🚀 Starting emulator: $avd"
    echo "   (This may take a minute...)"
    
    # Start emulator in background with GPU acceleration
    "$EMULATOR" -avd "$avd" -gpu host -no-snapshot-load &
    
    # Wait for emulator to boot
    echo "⏳ Waiting for emulator to boot..."
    "$ADB" wait-for-device
    
    # Wait for boot animation to complete
    while [ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
        sleep 2
    done
    
    echo "✅ Emulator ready!"
    "$ADB" devices
}

stop_emulator() {
    echo "🛑 Stopping emulator..."
    "$ADB" emu kill 2>/dev/null || echo "No emulator running"
}

show_status() {
    echo "📊 Emulator Status:"
    if "$ADB" devices | grep -q "emulator"; then
        echo "✅ Emulator is running"
        "$ADB" devices
        echo ""
        echo "Device info:"
        "$ADB" shell getprop ro.product.model 2>/dev/null
        "$ADB" shell getprop ro.build.version.release 2>/dev/null
    else
        echo "❌ No emulator running"
    fi
}

install_apk() {
    local apk="${1:-app/build/outputs/apk/debug/app-debug.apk}"
    
    if [ ! -f "$apk" ]; then
        echo "❌ APK not found: $apk"
        echo "   Run: ./gradlew assembleDebug"
        exit 1
    fi
    
    echo "📦 Installing APK..."
    "$ADB" install -r "$apk"
    echo "✅ Installed!"
}

show_logcat() {
    echo "📋 Showing logs (Ctrl+C to stop)..."
    # Filter for Swift, our app, and Python
    "$ADB" logcat -v time | grep -E "(Swift|AndroidExample|Python|PySwift|libSwift|System.out)"
}

# Main
case "${1:-help}" in
    start)
        start_emulator "$2"
        ;;
    stop)
        stop_emulator
        ;;
    status)
        show_status
        ;;
    list)
        list_avds
        ;;
    install)
        install_apk "$2"
        ;;
    logcat|log)
        show_logcat
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
