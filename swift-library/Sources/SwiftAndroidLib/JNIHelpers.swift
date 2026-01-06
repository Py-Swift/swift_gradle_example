// SwiftJava-lite: Simplified JNI helpers for Android
// Inspired by https://github.com/swiftlang/swift-java

#if os(Android)
import Android
#endif

// MARK: - JNI Environment Extension

/// Extension to make JNI calls more Swift-friendly
/// Based on swift-java's approach to JNI
public struct JNIEnvironment {
    public let env: UnsafeMutablePointer<JNIEnv?>
    
    public init(_ env: UnsafeMutablePointer<JNIEnv?>) {
        self.env = env
    }
    
    // MARK: - String Operations
    
    /// Create a new Java string from a Swift string
    public func newString(_ string: String) -> jstring? {
        string.withCString { cString in
            #if os(Android)
            return env.pointee?.pointee.NewStringUTF(env, cString)
            #else
            // Manual JNI function table access for non-Android platforms
            guard let functionsPtr = env.pointee else { return nil }
            let functionTable = functionsPtr.assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
            guard let newStringUTFPtr = functionTable[167] else { return nil }
            typealias NewStringUTFFunc = @convention(c) (
                UnsafeMutablePointer<JNIEnv?>?,
                UnsafePointer<CChar>?
            ) -> jstring?
            let newStringUTF = unsafeBitCast(newStringUTFPtr, to: NewStringUTFFunc.self)
            return newStringUTF(env, cString)
            #endif
        }
    }
    
    /// Get the UTF-8 characters from a Java string
    public func getStringUTFChars(_ javaString: jstring) -> String? {
        #if os(Android)
        var isCopy: jboolean = 0
        guard let chars = env.pointee?.pointee.GetStringUTFChars(env, javaString, &isCopy) else {
            return nil
        }
        defer {
            env.pointee?.pointee.ReleaseStringUTFChars(env, javaString, chars)
        }
        return String(cString: chars)
        #else
        return nil
        #endif
    }
    
    // MARK: - Array Operations
    
    /// Create a new Java object array
    public func newObjectArray(count: Int32, elementClass: jclass, initialElement: jobject? = nil) -> jobjectArray? {
        #if os(Android)
        return env.pointee?.pointee.NewObjectArray(env, count, elementClass, initialElement)
        #else
        return nil
        #endif
    }
    
    /// Set an element in a Java object array
    public func setObjectArrayElement(_ array: jobjectArray, index: Int32, value: jobject?) {
        #if os(Android)
        env.pointee?.pointee.SetObjectArrayElement(env, array, index, value)
        #endif
    }
    
    /// Get an element from a Java object array
    public func getObjectArrayElement(_ array: jobjectArray, index: Int32) -> jobject? {
        #if os(Android)
        return env.pointee?.pointee.GetObjectArrayElement(env, array, index)
        #else
        return nil
        #endif
    }
    
    /// Get the length of a Java array
    public func getArrayLength(_ array: jarray) -> Int32 {
        #if os(Android)
        return env.pointee?.pointee.GetArrayLength(env, array) ?? 0
        #else
        return 0
        #endif
    }
    
    // MARK: - Class Operations
    
    /// Find a Java class by name
    public func findClass(_ name: String) -> jclass? {
        #if os(Android)
        return name.withCString { cName in
            env.pointee?.pointee.FindClass(env, cName)
        }
        #else
        return nil
        #endif
    }
    
    /// Get the method ID for a method
    public func getMethodID(_ clazz: jclass, name: String, signature: String) -> jmethodID? {
        #if os(Android)
        return name.withCString { cName in
            signature.withCString { cSig in
                env.pointee?.pointee.GetMethodID(env, clazz, cName, cSig)
            }
        }
        #else
        return nil
        #endif
    }
    
    /// Get the method ID for a static method
    public func getStaticMethodID(_ clazz: jclass, name: String, signature: String) -> jmethodID? {
        #if os(Android)
        return name.withCString { cName in
            signature.withCString { cSig in
                env.pointee?.pointee.GetStaticMethodID(env, clazz, cName, cSig)
            }
        }
        #else
        return nil
        #endif
    }
    
    // MARK: - Object Operations
    
    /// Create a new Java object
    public func newObject(_ clazz: jclass, methodID: jmethodID, args: [jvalue] = []) -> jobject? {
        #if os(Android)
        var mutableArgs = args
        return mutableArgs.withUnsafeMutableBufferPointer { argsBuffer in
            env.pointee?.pointee.NewObjectA(env, clazz, methodID, argsBuffer.baseAddress)
        }
        #else
        return nil
        #endif
    }
    
    /// Call a void method on an object
    public func callVoidMethod(_ obj: jobject, methodID: jmethodID, args: [jvalue] = []) {
        #if os(Android)
        var mutableArgs = args
        mutableArgs.withUnsafeMutableBufferPointer { argsBuffer in
            env.pointee?.pointee.CallVoidMethodA(env, obj, methodID, argsBuffer.baseAddress)
        }
        #endif
    }
    
    /// Call a method that returns an object
    public func callObjectMethod(_ obj: jobject, methodID: jmethodID, args: [jvalue] = []) -> jobject? {
        #if os(Android)
        var mutableArgs = args
        return mutableArgs.withUnsafeMutableBufferPointer { argsBuffer in
            env.pointee?.pointee.CallObjectMethodA(env, obj, methodID, argsBuffer.baseAddress)
        }
        #else
        return nil
        #endif
    }
    
    /// Call a method that returns an int
    public func callIntMethod(_ obj: jobject, methodID: jmethodID, args: [jvalue] = []) -> jint {
        #if os(Android)
        var mutableArgs = args
        return mutableArgs.withUnsafeMutableBufferPointer { argsBuffer in
            env.pointee?.pointee.CallIntMethodA(env, obj, methodID, argsBuffer.baseAddress) ?? 0
        }
        #else
        return 0
        #endif
    }
    
    /// Call a method that returns a boolean
    public func callBooleanMethod(_ obj: jobject, methodID: jmethodID, args: [jvalue] = []) -> Bool {
        #if os(Android)
        var mutableArgs = args
        return mutableArgs.withUnsafeMutableBufferPointer { argsBuffer in
            (env.pointee?.pointee.CallBooleanMethodA(env, obj, methodID, argsBuffer.baseAddress) ?? 0) != 0
        }
        #else
        return false
        #endif
    }
    
    // MARK: - Static Method Calls
    
    /// Call a static method that returns an object
    public func callStaticObjectMethod(_ clazz: jclass, methodID: jmethodID, args: [jvalue] = []) -> jobject? {
        #if os(Android)
        var mutableArgs = args
        return mutableArgs.withUnsafeMutableBufferPointer { argsBuffer in
            env.pointee?.pointee.CallStaticObjectMethodA(env, clazz, methodID, argsBuffer.baseAddress)
        }
        #else
        return nil
        #endif
    }
    
    // MARK: - Exception Handling
    
    /// Check if an exception occurred
    public func exceptionCheck() -> Bool {
        #if os(Android)
        guard let result = env.pointee?.pointee.ExceptionCheck(env) else {
            return false
        }
        return result != 0
        #else
        return false
        #endif
    }
    
    /// Clear any pending exception
    public func exceptionClear() {
        #if os(Android)
        env.pointee?.pointee.ExceptionClear(env)
        #endif
    }
    
    /// Describe the pending exception to stderr
    public func exceptionDescribe() {
        #if os(Android)
        env.pointee?.pointee.ExceptionDescribe(env)
        #endif
    }
}

// MARK: - jvalue Helpers

#if os(Android)
extension jvalue {
    public static func object(_ obj: jobject?) -> jvalue {
        var v = jvalue()
        v.l = obj
        return v
    }
    
    public static func int(_ i: jint) -> jvalue {
        var v = jvalue()
        v.i = i
        return v
    }
    
    public static func long(_ l: jlong) -> jvalue {
        var v = jvalue()
        v.j = l
        return v
    }
    
    public static func float(_ f: jfloat) -> jvalue {
        var v = jvalue()
        v.f = f
        return v
    }
    
    public static func double(_ d: jdouble) -> jvalue {
        var v = jvalue()
        v.d = d
        return v
    }
    
    public static func boolean(_ b: Bool) -> jvalue {
        var v = jvalue()
        v.z = b ? 1 : 0
        return v
    }
}
#endif
