// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JustPassMe",
    products: [
        .library(
            name: "JustPassMeFramework",
            targets: ["JustPassMeFramework"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "JustPassMeFramework",
            path: "justpass-me/Frameworks/JustPassMeFramework.xcframework"
        )
    ]
)