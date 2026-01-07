package com.example.swiftandroid

/**
 * Bridge class for calling Swift native functions via JNI.
 * 
 * Phase 3: Swift-Java-Python full integration for Android
 * This class demonstrates the complete chain:
 * Kotlin/Java <-> Swift <-> Python
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
            
            // Load Python library (Phase 3)
            tryLoadLibrary("python3.13")
            
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
    
    /**
     * Initialize PyPlayground module from Swift.
     * Simple test that PyPlayground is loaded and working.
     * 
     * @return Result message
     */
    external fun initPyPlayground(): String
    // ============== Phase 3: Python Integration ==============
    
    /**
     * Initialize Python interpreter from Swift.
     * Must be called before any Python operations.
     * 
     * @param pythonHome Path to Python home directory
     * @return true if initialization succeeded
     */
    external fun initializePython(pythonHome: String): Boolean
    
    /**
     * Shutdown Python interpreter.
     */
    external fun finalizePython()
    
    /**
     * Check if Python is initialized.
     * 
     * @return true if Python is ready
     */
    external fun isPythonInitialized(): Boolean
    
    /**
     * Get Python version string.
     * 
     * @return Python version
     */
    external fun getPythonVersion(): String
    
    /**
     * Run Python code from Swift.
     * 
     * @param code Python code to execute
     * @return Result message
     */
    external fun runPythonCode(code: String): String
    
    /**
     * Get Python demo information.
     * Shows the full chain: Kotlin -> Swift -> Python
     * 
     * @return Demo info string
     */
    external fun getPythonDemoInfo(): String
}
