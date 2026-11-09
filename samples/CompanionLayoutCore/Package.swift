// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CompanionLayoutCore",
    products: [
        .library(name: "CompanionLayoutCore", targets: ["CompanionLayoutCore"])
    ],
    targets: [
        .target(name: "CompanionLayoutCore"),
        .testTarget(name: "CompanionLayoutCoreTests", dependencies: ["CompanionLayoutCore"])
    ]
)
