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
            url: "https://github.com/Skycoder42/libsodium_dart_bindings/releases/download/libsodium-binaries/v1.0.20%2B12444106604/libsodium-1.0.20-darwin.tar.xz",
            checksum: "79a041ab28ae2ad4a590ff5c6f19c9530d130be37ebe08e8521a78e4e6f9c97831912c6f1ab0d99843e8504ba47b5fdff47a384a89f0c68782567c8db4d81150"
        ),
    ]
)
