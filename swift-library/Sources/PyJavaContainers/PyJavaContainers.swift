// PyJavaContainers - Swift types exported to Java via JExtract
// Public Swift types are automatically exported to Java

#if os(Linux)
import Glibc
#elseif os(Android)
import Android
#else
import Darwin.C
#endif

import SwiftJava
import PySwiftKit
import PySwiftWrapper
import PySerializing

// Helper for logging
func plog(_ msg: String, file: String = #fileID, line: UInt = #line, function: String = #function) {
    print("[swift][\(file):\(line)](\(function)) \(msg)")
    fflush(stdout)
}

/// Container class that holds Python callbacks
/// Exported to Java via JExtract so Kotlin can call these methods
@PyContainer
public final class PySwiftDataContainer: PyDeserialize {

    /// Callback that receives text from Kotlin
    @PyCall
    public func cb_0(text: String) {
        plog("cb_0 called with text: \(text)")
    }

    /// Callback that receives numbers from Kotlin  
    @PyCall
    public func cb_1(numbers: [Int64]) {
        plog("cb_1 called with numbers: \(numbers)")
    }
}