package com.example.swiftandroid

/**
 * Bridge class for calling Swift native functions via JNI.
 * 
 * Phase 2: Swift-Java style interop for Android
 * This class demonstrates calling Swift functions that in turn
 * call back into Java via JNI - similar to swift-java patterns.
 */
object SwiftBridge {
    
    init {
        try {
            // Load Swift runtime libraries first (order matters!)
            // These are bundled from the Swift SDK for Android
            System.loadLibrary("swiftCore")
            
            // Optional libraries - may not exist in all Swift SDK versions
            tryLoadLibrary("swiftGlibc")
            
            System.loadLibrary("dispatch")
            System.loadLibrary("BlocksRuntime")
            
            // Load our Swift library
            System.loadLibrary("SwiftAndroidLib")
            
        } catch (e: UnsatisfiedLinkError) {
            System.err.println("Failed to load Swift libraries: ${e.message}")
            throw e
        }
    }
    
    private fun tryLoadLibrary(name: String) {
        try {
            System.loadLibrary(name)
        } catch (e: UnsatisfiedLinkError) {
            // Library not found - this is OK for optional libraries
            System.err.println("Optional library $name not found, continuing...")
        }
    }
    
    /**
     * Get a greeting message from Swift.
     * This calls into the Swift function via JNI.
     */
    external fun getGreetingFromSwift(): String
    
    /**
     * Parse CSV data using Swift.
     * Demonstrates passing strings between Kotlin and Swift.
     * 
     * @param csvData The CSV data to parse
     * @return Formatted string representation of the parsed data
     */
    external fun parseCSV(csvData: String): String
    
    /**
     * Parse CSV data using Swift calling back to Java's String.split.
     * Demonstrates Swift calling Java methods via JNI.
     * 
     * @param csvData The CSV data to parse
     * @return Formatted string representation of the parsed data
     */
    external fun parseCSVWithJava(csvData: String): String
    
    /**
     * Get system information via Java System.getProperty called from Swift.
     * Demonstrates Swift calling Java static methods.
     * 
     * @return System information string
     */
    external fun getSystemInfo(): String
}
