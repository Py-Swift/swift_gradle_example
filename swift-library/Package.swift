// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftAndroidLib",
    products: [
        .library(
            name: "SwiftAndroidLib",
            type: .dynamic,
            targets: ["SwiftAndroidLib"]
        )
    ],
    targets: [
        .target(
            name: "SwiftAndroidLib",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("Extern")
            ]
        )
    ]
)
