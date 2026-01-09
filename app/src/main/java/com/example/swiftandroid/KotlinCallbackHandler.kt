package com.example.swiftandroid

import com.example.swift.containers.PySwiftDataContainer

/**
 * Kotlin callback handler that receives PySwiftDataContainer from Swift
 * and invokes its callback methods.
 */
object KotlinCallbackHandler {
    
    /**
     * Called from Swift to invoke callbacks on the container.
     * This demonstrates the Swift -> Kotlin -> Swift callback chain.
     * 
     * @param container The PySwiftDataContainer exported from Swift via JExtract
     */
    @JvmStatic
    fun invokeCallbacks(container: PySwiftDataContainer) {
        println("[Kotlin] Received PySwiftDataContainer from Swift")
        
        // Call cb_0 with a test string
        println("[Kotlin] Calling cb_0 with text...")
        container.cb_0("Hello from Kotlin!")
        
        // Call cb_1 with a test array of Int64 (Long in Java/Kotlin)
        println("[Kotlin] Calling cb_1 with numbers...")
        container.cb_1(longArrayOf(1L, 2L, 3L, 4L, 5L))
        
        println("[Kotlin] Callbacks complete!")
    }
}
