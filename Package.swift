// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCUITestAgent",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "XCUITestAgent",
            targets: ["XCUITestAgent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI", from: "0.3.8")
    ],
    targets: [
        .target(
            name: "XCUITestAgent",
            dependencies: [
                "OpenAI",
            ]
        ),
    ]
)
