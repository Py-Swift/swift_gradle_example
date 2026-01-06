import Foundation

// MARK: - JNI Interface

/// This function is called from Java/Kotlin via JNI to get a greeting message.
/// The function name follows JNI naming convention:
/// Java_<package>_<class>_<method> with underscores replaced by _1
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getGreetingFromSwift")
public func getGreetingFromSwift(
    env: UnsafeMutableRawPointer?,
    thisObj: UnsafeMutableRawPointer?
) -> UnsafeMutableRawPointer? {
    let greeting = createGreeting()
    return createJavaString(env: env, string: greeting)
}

/// Get a greeting message - this is the Swift logic
func createGreeting() -> String {
    return "Hello from Swift! 🚀\nRunning on Android via Swift SDK"
}

// MARK: - JNI Helpers

/// Creates a Java String from a Swift String
private func createJavaString(env: UnsafeMutableRawPointer?, string: String) -> UnsafeMutableRawPointer? {
    guard let env = env else { return nil }
    
    // Get JNIEnv pointer
    let jniEnv = env.assumingMemoryBound(to: UnsafeMutablePointer<JNINativeInterface_>.self).pointee
    
    // Create Java string using NewStringUTF
    guard let newStringUTF = jniEnv?.pointee.NewStringUTF else { return nil }
    
    return string.withCString { cString in
        newStringUTF(env, cString)
    }
}

// MARK: - JNI Types (minimal definitions needed for string creation)

/// Minimal JNI interface structure for creating strings
struct JNINativeInterface_ {
    // Padding for JNI function table - NewStringUTF is at index 167
    private var reserved0: UnsafeMutableRawPointer?
    private var reserved1: UnsafeMutableRawPointer?
    private var reserved2: UnsafeMutableRawPointer?
    private var reserved3: UnsafeMutableRawPointer?
    
    // JNI functions 4-166 (we skip to NewStringUTF)
    private var padding: (
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?
    ) = (
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil
    )
    
    // Index 167: NewStringUTF
    var NewStringUTF: (@convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CChar>?) -> UnsafeMutableRawPointer?)?
}
