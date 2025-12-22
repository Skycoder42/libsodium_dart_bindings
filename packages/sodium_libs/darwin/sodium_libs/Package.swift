// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sodium_libs",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15")
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
            url: "https://github.com/Skycoder42/libsodium_dart_bindings/releases/download/untagged-67f66b62c7fa2e9a00f1/libsodium-1.0.20-darwin.zip",
            checksum: "d516162c3765adad80d85868a4a166669ba05b5e477f78b77b6c3d1932194bf5"
        ),
    ]
)
