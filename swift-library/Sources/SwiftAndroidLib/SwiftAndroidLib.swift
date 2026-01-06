// Swift Android Library - JNI Bridge
// Phase 2: Swift-Java style interop for Android
// Inspired by https://github.com/swiftlang/swift-java

#if os(Android)
import Android
#endif

// MARK: - JNI Interface

/// This function is called from Java/Kotlin via JNI to get a greeting message.
/// Uses the JNIHelpers for cleaner JNI interaction.
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getGreetingFromSwift")
public func getGreetingFromSwift(
    env: UnsafeMutablePointer<JNIEnv?>?,
    thisObj: jobject?
) -> jstring? {
    guard let env = env else { return nil }
    
    let jniEnv = JNIEnvironment(env)
    
    let greeting = """
        Hello from Swift! 🚀
        Running on Android via Swift SDK
        
        Phase 2: Swift-Java Style Interop
        ────────────────────────────────
        This app demonstrates calling Java
        methods from Swift via JNI, similar
        to the swift-java library approach.
        """
    
    return jniEnv.newString(greeting)
}
