// swift-tools-version: 6.1
// Swift library for Android using swift-java with JNI mode

import CompilerPluginSupport
import PackageDescription
import Foundation

// JAVA_HOME detection for JNI headers
func findJavaHome() -> String {
    if let home = ProcessInfo.processInfo.environment["JAVA_HOME"] {
        return home
    }
    
    // macOS fallback
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/libexec/java_home")
    let pipe = Pipe()
    task.standardOutput = pipe
    
    do {
        try task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           task.terminationStatus == 0 {
            return output
        }
    } catch {}
    
    fatalError("Please set the JAVA_HOME environment variable")
}

let javaHome = findJavaHome()
let javaIncludePath = "\(javaHome)/include"

#if os(Linux)
let javaPlatformIncludePath = "\(javaIncludePath)/linux"
#elseif os(macOS)
let javaPlatformIncludePath = "\(javaIncludePath)/darwin"
#elseif os(Android)
let javaPlatformIncludePath = "\(javaIncludePath)/linux"
#else
let javaPlatformIncludePath = javaIncludePath
#endif

let package = Package(
    name: "SwiftAndroidLib",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftAndroidLib",
            type: .dynamic,
            targets: ["SwiftAndroidLib"]
        )
    ],
    dependencies: [
        // Use local swift-java for development
        .package(name: "swift-java", path: "/Volumes/CodeSSD/GitHub/swift-java")
    ],
    targets: [
        // Target that wraps Java CSV library for use in Swift
        .target(
            name: "JavaCSV",
            dependencies: [
                .product(name: "SwiftJava", package: "swift-java"),
                .product(name: "JavaUtil", package: "swift-java"),
                .product(name: "JavaIO", package: "swift-java"),
            ],
            exclude: ["swift-java.config"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .unsafeFlags(["-I\(javaIncludePath)", "-I\(javaPlatformIncludePath)"])
            ],
            plugins: [
                .plugin(name: "SwiftJavaPlugin", package: "swift-java")
            ]
        ),
        
        // Main library that uses the wrapped Java CSV
        .target(
            name: "SwiftAndroidLib",
            dependencies: [
                "JavaCSV",
                .product(name: "SwiftJava", package: "swift-java"),
                .product(name: "CSwiftJavaJNI", package: "swift-java"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .unsafeFlags(["-I\(javaIncludePath)", "-I\(javaPlatformIncludePath)"])
            ]
        )
    ]
)
