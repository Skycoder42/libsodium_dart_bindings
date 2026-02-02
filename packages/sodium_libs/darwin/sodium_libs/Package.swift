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
        .library(name: "sodium-libs", targets: ["sodium_libs",])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "sodium_libs",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
