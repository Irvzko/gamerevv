// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameRev",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "GameRev",
            targets: ["GameRev"]
        )
    ],
    targets: [
        .target(
            name: "GameRev",
            path: "GameRev",
            exclude: [
                "Info.plist",
                "Assets.xcassets"
            ]
        )
    ]
)
