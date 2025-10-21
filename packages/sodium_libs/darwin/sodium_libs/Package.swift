// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sodium_libs",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "sodium-libs", targets: ["sodium_libs", "libsodium"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "sodium_libs",
            dependencies: ["libsodium"],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
        .binaryTarget(
            name: "libsodium",
            url: "https://github.com/Skycoder42/libsodium_dart_bindings/releases/download/libsodium-binaries/v1.0.20%2B18671922006/libsodium-1.0.20-darwin.zip",
            checksum: "c55362d2ebc86fa7b89a1e161c49cbd83c2ceecba9a1ea8ad982f8ff7e2ab756"
        ),
    ]
)
