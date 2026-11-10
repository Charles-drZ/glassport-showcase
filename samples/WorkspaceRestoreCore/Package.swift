// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WorkspaceRestoreCore",
    products: [
        .library(name: "WorkspaceRestoreCore", targets: ["WorkspaceRestoreCore"])
    ],
    targets: [
        .target(name: "WorkspaceRestoreCore"),
        .testTarget(name: "WorkspaceRestoreCoreTests", dependencies: ["WorkspaceRestoreCore"])
    ]
)
