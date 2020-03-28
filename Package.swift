// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "RayTracing",
        platforms: [
            .macOS(.v10_15),
        ],
        dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.1"),
        ],
        targets: [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages which this package depends on.
            .target(
                    name: "weekend",
                    dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
            .testTarget(
                    name: "weekendTests",
                    dependencies: ["weekend"]),
        ]
)
