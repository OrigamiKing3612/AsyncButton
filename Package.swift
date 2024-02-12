// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncButton",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "AsyncButton",
            targets: ["AsyncButton"]),
    ],
    targets: [
        .target(
            name: "AsyncButton"),
        .testTarget(
            name: "AsyncButtonTests",
            dependencies: ["AsyncButton"]),
    ]
)
