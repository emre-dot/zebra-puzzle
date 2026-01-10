// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZebraPuzzlePro",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ZebraPuzzlePro",
            targets: ["ZebraPuzzlePro"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ZebraPuzzlePro",
            dependencies: [],
            path: "src",
            exclude: [],
            resources: [
                .process("Data/Themes") // Process the JSON themes as resources
            ]
        )
    ]
)
