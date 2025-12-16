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
            url: "https://github.com/Skycoder42/libsodium_dart_bindings/releases/download/untagged-477c3abe019cc3b946ef/libsodium-1.0.20-darwin.zip",
            checksum: "300ea0f02fd1bd6e61d1d679cd690a5a2424f2dc911442e628df27fa296f49c1"
        ),
    ]
)
