package com.example.swiftandroid

/**
 * Bridge class for calling Swift native functions via JNI.
 * 
 * This class loads the Swift library and Swift runtime dependencies,
 * then exposes native methods that are implemented in Swift.
 */
object SwiftBridge {
    
    init {
        try {
            // Load Swift runtime libraries first (order matters!)
            // These are bundled from the Swift SDK for Android
            System.loadLibrary("swiftCore")
            System.loadLibrary("swiftGlibc")
            System.loadLibrary("dispatch")
            System.loadLibrary("BlocksRuntime")
            
            // Load our Swift library
            System.loadLibrary("SwiftAndroidLib")
            
        } catch (e: UnsatisfiedLinkError) {
            System.err.println("Failed to load Swift libraries: ${e.message}")
            throw e
        }
    }
    
    /**
     * Get a greeting message from Swift.
     * This calls into the Swift function via JNI.
     */
    external fun getGreetingFromSwift(): String
}
