// Swift Android Library - Swift-Java Integration
// This demonstrates: Kotlin/Java <-> Swift

#if canImport(Android)
import Android
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

import SwiftJava
import JavaCSV
import PyPlayground
import PySwiftLauncher
import PySwiftKit
import Foundation
import JavaIO

// MARK: - CSV Processing using Java Library

/// Parse CSV data using Apache Commons CSV (Java library) from Swift
/// This is the key Phase 2 feature: Swift calling Java libraries via swift-java
public func parseCSVWithJava(_ csvData: String, environment: JNIEnvironment) throws -> String {
    // Get the CSVFormat class and use RFC4180 format
    let csvFormatClass = try JavaClass<CSVFormat>(environment: environment)
    guard let format = csvFormatClass.RFC4180 else {
        return "Error: Could not get RFC4180 format"
    }
    
    // Create a StringReader from the CSV data
    let reader = StringReader(csvData, environment: environment)
    
    // Parse the CSV using the Java library
    guard let parser = try format.parse(reader) else {
        return "Error: Could not create parser"
    }
    guard let records = parser.getRecords() else {
        return "Error: Could not get records"
    }
    
    var result = "📊 CSV Parsed by Java (Apache Commons CSV):\n"
    result += String(repeating: "─", count: 45) + "\n"
    
    var rowIndex = 0
    for record in records {
        guard let fields = record.toList() else { continue }
        
        if rowIndex == 0 {
            result += "Headers: "
        } else {
            result += "Row \(rowIndex): "
        }
        
        var fieldStrings: [String] = []
        for field in fields {
            fieldStrings.append("\(field)")
        }
        result += fieldStrings.joined(separator: " | ")
        result += "\n"
        
        if rowIndex == 0 {
            result += String(repeating: "─", count: 45) + "\n"
        }
        rowIndex += 1
    }
    
    return result
}

// MARK: - Pure Swift Functions (from Phase 1)

/// Get a greeting message from Swift
public func getGreetingFromSwift() -> String {
    return """
        Hello from Swift! 🚀
        Running on Android via Swift SDK
        
        Phase 2: swift-java Integration
        ────────────────────────────────
        Now using swift-java to call
        Java libraries from Swift!

        Phase 3: PySwiftKit Integration
        ────────────────────────────────
        Bundle.main \(Bundle.main.bundlePath)
        """
}

/// Simple counter to demonstrate stateful operations
nonisolated(unsafe) private var counter: Int64 = 0

/// Increment and return the counter value
public func incrementCounter() -> Int64 {
    counter += 1
    return counter
}

/// Get the current counter value
public func getCounter() -> Int64 {
    return counter
}

/// Reset the counter
public func resetCounter() {
    counter = 0
}

// MARK: - JNI Exports for Android

import CSwiftJavaJNI

/// JNI export for getGreetingFromSwift
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getGreetingFromSwift")
public func jni_getGreetingFromSwift(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jstring? {
    let greeting = getGreetingFromSwift()
    return env?.pointee?.pointee.NewStringUTF(env, greeting)
}

/// JNI export for incrementCounter
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_incrementCounter")
public func jni_incrementCounter(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jlong {
    return jlong(incrementCounter())
}

/// JNI export for getCounter
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getCounter")
public func jni_getCounter(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jlong {
    return jlong(getCounter())
}

/// JNI export for resetCounter
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_resetCounter")
public func jni_resetCounter(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) {
    resetCounter()
}

/// JNI export for parseCSV (pure Swift)
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_parseCSV")
public func jni_parseCSV(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?,
    _ csvData: jstring?
) -> jstring? {
    guard let env = env, let csvData = csvData else { return nil }
    
    // Convert Java string to Swift string
    guard let chars = env.pointee?.pointee.GetStringUTFChars(env, csvData, nil) else {
        return nil
    }
    let swiftString = String(cString: chars)
    env.pointee?.pointee.ReleaseStringUTFChars(env, csvData, chars)
    
    // Parse and return result
    let result = parseCSV(swiftString)
    return env.pointee?.pointee.NewStringUTF(env, result)
}

/// JNI export for getBuildInfo
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getBuildInfo")
public func jni_getBuildInfo(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jstring? {
    let info = getBuildInfo()
    return env?.pointee?.pointee.NewStringUTF(env, info)
}

/// JNI export for parseCSVWithJava (uses Apache Commons CSV)
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_parseCSVWithJava")
public func jni_parseCSVWithJava(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?,
    _ csvData: jstring?
) -> jstring? {
    guard let env = env, let csvData = csvData else { return nil }
    
    // Convert Java string to Swift string  
    guard let chars = env.pointee?.pointee.GetStringUTFChars(env, csvData, nil) else {
        return nil
    }
    let swiftString = String(cString: chars)
    env.pointee?.pointee.ReleaseStringUTFChars(env, csvData, chars)
    
    // Create JNI environment wrapper for swift-java
    let jniEnv = JNIEnvironment(env)
    
    do {
        let result = try parseCSVWithJava(swiftString, environment: jniEnv)
        return env.pointee?.pointee.NewStringUTF(env, result)
    } catch {
        let errorMsg = "Error parsing CSV with Java: \(error)"
        return env.pointee?.pointee.NewStringUTF(env, errorMsg)
    }
}

/// JNI export for initPyPlayground - simple test of PyPlayground module
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_initPyPlayground")
public func jni_initPyPlayground(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jstring? {
    guard let env = env else { return nil }
    
    let playground = PyPlayground()
    return env.pointee?.pointee.NewStringUTF(env, playground.value)
}

@_cdecl("Java_com_example_swiftandroid_SwiftBridge_usePySwiftKit")
public func jni_usePySwiftKit(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
)  {
    guard let env = env else { return }
    
    
}

/// JNI export for getSystemInfo
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getSystemInfo")
public func jni_getSystemInfo(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jstring? {
    guard let env = env else { return nil }
    
    let info = getSystemInfoViaJNI(env)
    return env.pointee?.pointee.NewStringUTF(env, info)
}

/// Get system information by calling Java's System.getProperty via direct JNI
public func getSystemInfoViaJNI(_ env: UnsafeMutablePointer<JNIEnv?>?) -> String {
    guard let env = env else { return "Error: No JNI environment" }
    
    var info = "📱 System Info (via Java JNI):\n"
    info += String(repeating: "─", count: 40) + "\n"
    
    // Find java.lang.System class
    guard let systemClass = env.pointee?.pointee.FindClass(env, "java/lang/System") else {
        info += "Error: Could not find System class\n"
        return info
    }
    
    // Get the getProperty method ID
    guard let getPropertyMethod = env.pointee?.pointee.GetStaticMethodID(
        env, systemClass, "getProperty", "(Ljava/lang/String;)Ljava/lang/String;"
    ) else {
        info += "Error: Could not find getProperty method\n"
        return info
    }
    
    // Helper function to get a system property
    func getProperty(_ key: String) -> String? {
        guard let keyString = env.pointee?.pointee.NewStringUTF(env, key) else { return nil }
        defer { env.pointee?.pointee.DeleteLocalRef(env, keyString) }
        
        guard let result = env.pointee?.pointee.CallStaticObjectMethodA(
            env, systemClass, getPropertyMethod, [jvalue(l: keyString)]
        ) else { return nil }
        defer { env.pointee?.pointee.DeleteLocalRef(env, result) }
        
        guard let chars = env.pointee?.pointee.GetStringUTFChars(env, result, nil) else { return nil }
        let swiftString = String(cString: chars)
        env.pointee?.pointee.ReleaseStringUTFChars(env, result, chars)
        return swiftString
    }
    
    // Get various system properties
    if let osName = getProperty("os.name") {
        info += "OS Name: \(osName)\n"
    }
    if let osVersion = getProperty("os.version") {
        info += "OS Version: \(osVersion)\n"
    }
    if let osArch = getProperty("os.arch") {
        info += "Architecture: \(osArch)\n"
    }
    if let javaVersion = getProperty("java.version") {
        info += "Java Version: \(javaVersion)\n"
    }
    if let vmName = getProperty("java.vm.name") {
        info += "VM Name: \(vmName)\n"
    }
    
    info += String(repeating: "─", count: 40) + "\n"
    info += "✅ Swift called Java successfully!"
    
    return info
}

/// Pure Swift CSV parsing (for comparison)
public func parseCSV(_ csvData: String) -> String {
    var result = "📊 CSV Parsed by Swift (Pure Swift):\n"
    result += String(repeating: "─", count: 40) + "\n"
    
    let lines = csvData.split(separator: "\n", omittingEmptySubsequences: false)
    
    for (rowIndex, line) in lines.enumerated() {
        var cleanLine = String(line)
        if cleanLine.hasSuffix("\r") {
            cleanLine.removeLast()
        }
        guard !cleanLine.isEmpty else { continue }
        
        let fields = cleanLine.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        
        if rowIndex == 0 {
            result += "Headers: \(fields.joined(separator: " | "))\n"
            result += String(repeating: "─", count: 40) + "\n"
        } else {
            result += "Row \(rowIndex): \(fields.joined(separator: " | "))\n"
        }
    }
    
    return result
}

/// Get build information
public func getBuildInfo() -> String {
    var info = "🔧 Swift Build Info:\n"
    info += String(repeating: "─", count: 40) + "\n"
    
    #if os(Android)
    info += "Platform: Android\n"
    #elseif os(Linux)
    info += "Platform: Linux\n"
    #elseif os(macOS)
    info += "Platform: macOS\n"
    #else
    info += "Platform: Unknown\n"
    #endif
    
    #if arch(arm64)
    info += "Architecture: ARM64\n"
    #elseif arch(x86_64)
    info += "Architecture: x86_64\n"
    #else
    info += "Architecture: Unknown\n"
    #endif
    
    info += "swift-java: JNI Mode\n"
    
    return info
}

// MARK: - Internal helpers

func p(_ msg: String, file: String = #fileID, line: UInt = #line, function: String = #function) {
    print("[swift][\(file):\(line)](\(function)) \(msg)")
    #if canImport(Android) || canImport(Glibc) || canImport(Darwin)
    fflush(stdout)
    #endif
}

// MARK: - Python Integration (Phase 3)

/// Global Python home path
nonisolated(unsafe) private var pythonHomePath: String = ""

/// JNI export for initializePython
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_initializePython")
public func jni_initializePython(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?,
    _ pythonHome: jstring?
) -> jboolean {
    guard let env = env, let pythonHome = pythonHome else { return jboolean(JNI_FALSE) }
    
    // Convert Java string to Swift string
    guard let chars = env.pointee?.pointee.GetStringUTFChars(env, pythonHome, nil) else {
        return jboolean(JNI_FALSE)
    }
    pythonHomePath = String(cString: chars)
    env.pointee?.pointee.ReleaseStringUTFChars(env, pythonHome, chars)
    
    p("Initializing Python with home: \(pythonHomePath)")
    
    // Derive resourcePath and prog from pythonHome
    // pythonHome = /data/.../files/python
    // resourcePath = /data/.../files (parent)
    // prog = /data/.../files/app/__main__.py
    let resourcePath = (pythonHomePath as NSString).deletingLastPathComponent
    let prog = "\(resourcePath)/app/__main__.py"
    
    p("Derived resourcePath: \(resourcePath)")
    p("Derived prog: \(prog)")
    
    PySwiftLauncher.shared.setResourcePath(resourcePath)
    PySwiftLauncher.shared.setProg(prog)
    
    // Set environment variables for Python
    setenv("PYTHONHOME", pythonHomePath, 1)
    setenv("PYTHONPATH", pythonHomePath, 1)
    setenv("PYTHONDONTWRITEBYTECODE", "1", 1)
    setenv("PYTHONNOUSERSITE", "1", 1)
    
    p("Python environment configured")
    return jboolean(JNI_TRUE)
}

/// JNI export for finalizePython
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_finalizePython")
public func jni_finalizePython(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) {
    p("Finalizing Python")
    Py_FinalizeEx()
}

/// JNI export for isPythonInitialized
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_isPythonInitialized")
public func jni_isPythonInitialized(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jboolean {
    return Py_IsInitialized() != 0 ? jboolean(JNI_TRUE) : jboolean(JNI_FALSE)
}

/// JNI export for getPythonVersion
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getPythonVersion")
public func jni_getPythonVersion(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jstring? {
    guard let env = env else { return nil }
    let version = PySwiftLauncher.shared.PYTHON_VERSION
    return env.pointee?.pointee.NewStringUTF(env, version)
}

/// JNI export for runPythonCode
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_runPythonCode")
public func jni_runPythonCode(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?,
    _ code: jstring?
) -> jstring? {
    guard let env = env, let code = code else { return nil }
    
    // Convert Java string to Swift string
    guard let chars = env.pointee?.pointee.GetStringUTFChars(env, code, nil) else {
        return nil
    }
    let pythonCode = String(cString: chars)
    env.pointee?.pointee.ReleaseStringUTFChars(env, code, chars)
    
    p("Running Python code: \(pythonCode.prefix(50))...")
    
    let result = PySwiftLauncher.shared.runCode(pythonCode)
    let message = result == 0 ? "✅ Python code executed successfully" : "❌ Python code execution failed with code: \(result)"
    
    return env.pointee?.pointee.NewStringUTF(env, message)
}

/// JNI export for getPythonDemoInfo
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_getPythonDemoInfo")
public func jni_getPythonDemoInfo(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jstring? {
    guard let env = env else { return nil }
    
    var info = "🐍 Python Integration (Phase 3)\n"
    info += String(repeating: "─", count: 40) + "\n"
    info += "PYTHONHOME: \(pythonHomePath)\n"
    info += "Version: \(PySwiftLauncher.shared.PYTHON_VERSION)\n"
    info += "Initialized: \(Py_IsInitialized() != 0 ? "Yes" : "No")\n"
    info += "App Path: \(PySwiftLauncher.shared.prog ?? "not set")\n"
    info += String(repeating: "─", count: 40) + "\n"
    info += "Chain: Kotlin → Swift → Python ✅"
    
    return env.pointee?.pointee.NewStringUTF(env, info)
}

/// JNI export for setPythonAppPath - set the path to __main__.py
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_setPythonAppPath")
public func jni_setPythonAppPath(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?,
    _ appPath: jstring?
) {
    guard let env = env, let appPath = appPath else { return }
    
    // Convert Java string to Swift string
    guard let chars = env.pointee?.pointee.GetStringUTFChars(env, appPath, nil) else {
        return
    }
    let path = String(cString: chars)
    env.pointee?.pointee.ReleaseStringUTFChars(env, appPath, chars)
    
    p("Setting Python app path: \(path)")
    PySwiftLauncher.shared.setProg(path)
}

/// JNI export for runPythonApp - run the __main__.py file
@_cdecl("Java_com_example_swiftandroid_SwiftBridge_runPythonApp")
public func jni_runPythonApp(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ thisObj: jobject?
) -> jint {
    p("Running Python app via PySwiftLauncher")
    
    // Cache JNI environment for Python → Swift → Java calls
    cachedJNIEnv = env
    
    do {
        // Run the app
        var argv: [UnsafeMutablePointer<CChar>?] = []

        try PySwiftLauncher.run(0, &argv)
        p("Python app finished execution")
        return 0
    } catch {
        p("Error running Python app: \(error)")
        return -1
    }
}
