// swift-tools-version: 6.0
// CPython for Android - Minimal wrapper for Swift

import PackageDescription

let package = Package(
    name: "CPython",
    products: [
        .library(
            name: "CPython",
            targets: ["CPython"]
        )
    ],
    targets: [
        .target(
            name: "CPython",
            sources: ["CPython.c"],
            publicHeadersPath: "include",
            cSettings: [
                .define("PY_SSIZE_T_CLEAN"),
                .headerSearchPath("../../PythonHeaders"),
            ],
            linkerSettings: [
                .linkedLibrary("python3.13"),
            ]
        ),
    ]
)
