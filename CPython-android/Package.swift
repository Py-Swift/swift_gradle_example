// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let processInfo = ProcessInfo.processInfo


enum BuildPlatform: String {
    case apple
    case linux
    case windows
    case android
    case webassembly
}

func getPlatform() -> BuildPlatform {
    if processInfo.environment["SWIFT_ANDROID_HOME"] != nil {
        return .android
    }

    return .apple
}

func getTargets() -> [Target] {
    let platform = getPlatform()
    switch platform {
    case .android:

        return [
            .target(
                name: "CPython",
                path: "Sources/CPython",
                publicHeadersPath: ".",
                cSettings: [
                    .define("PY_SSIZE_T_CLEAN"),
                    .headerSearchPath("../../PythonHeaders"),
                ],
                swiftSettings: [
                    .swiftLanguageMode(.v5)
                ],
                linkerSettings: [
                    .linkedLibrary("python3.13"),
                ],
                
            )
        ]
    case .linux, .windows, .webassembly:
        fatalError("CPython package is not supported on \(platform) yet.")
    case .apple:
        let pythonPath = "Frameworks/Python.xcframework"

        let pythonBinaryTarget = Target.binaryTarget(
            name: "Python",
            path: pythonPath
        )
        return [
            .target(
                name: "CPython",
                dependencies: [
                    "Python"
                ],
                path: "Sources/CPython",
                publicHeadersPath: ".",
                swiftSettings: [
                    .swiftLanguageMode(.v5)
                ],

            ),
            pythonBinaryTarget
        ]
    }
}


// old target definition:
// let cPythonTarget = Target.target(
//     name: "CPython",
//     dependencies: [
//         "Python"
//     ],
//     path: "Sources/CPython",
//     publicHeadersPath: "."

// )



let package = Package(
    name: "CPython",
    products: [
        .library(
            name: "CPython",
            targets: [
                "CPython"
            ]
        )
    ],
    targets: getTargets()
)
