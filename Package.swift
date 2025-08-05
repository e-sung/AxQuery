// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AxQuery",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "AxQuery",
            targets: ["AxQuery"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AxQuery",
            dependencies: []),
        .testTarget(
            name: "AxQueryTests",
            dependencies: ["AxQuery"]),
    ]
)