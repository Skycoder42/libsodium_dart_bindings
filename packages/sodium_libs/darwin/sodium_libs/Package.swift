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
            url: "https://github.com/Skycoder42/libsodium_dart_bindings/releases/download/libsodium-binaries/v1.0.20%2B17905942073/libsodium-1.0.20-darwin.zip",
            checksum: "1cd869a18ef317d3632aaaeaad24a088653da998b114ef799052f0cf817437b8"
        ),
    ]
)
