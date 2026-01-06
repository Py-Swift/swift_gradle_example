// Swift Android Library - JNI Bridge
// Note: We avoid importing Foundation to simplify Android cross-compilation

// MARK: - JNI Types

/// JNI function signature for NewStringUTF
typealias NewStringUTFFunc = @convention(c) (
    UnsafeMutablePointer<UnsafeMutableRawPointer?>?,  // JNIEnv*
    UnsafePointer<CChar>?                              // const char*
) -> UnsafeMutableRawPointer?                          // jstring

// MARK: - JNI Interface

/// This function is called from Java/Kotlin via JNI to get a greeting message.
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getGreetingFromSwift")
public func getGreetingFromSwift(
    env: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
    thisObj: UnsafeMutableRawPointer?
) -> UnsafeMutableRawPointer? {
    guard let env = env else { return nil }
    
    let greeting = "Hello from Swift! 🚀\nRunning on Android via Swift SDK"
    
    return greeting.withCString { cString in
        // JNIEnv is JNINativeInterface** - we need to get the function table
        // env points to JNIEnv*, which points to JNINativeInterface*
        guard let functionsPtr = env.pointee else { return nil }
        
        // The JNI function table is an array of function pointers
        // NewStringUTF is at index 167 in the JNI function table
        let functionTable = functionsPtr.assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
        
        guard let newStringUTFPtr = functionTable[167] else { return nil }
        
        let newStringUTF = unsafeBitCast(newStringUTFPtr, to: NewStringUTFFunc.self)
        return newStringUTF(env, cString)
    }
}
