// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NoroPlayer",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "NoroPlayer",
            dependencies: ["NoroPlayerLib"],
            path: "Sources/NoroPlayerMain",
            exclude: ["Info.plist", "NoroPlayer.entitlements"]
        ),
        .target(
            name: "NoroPlayerLib",
            path: "Sources/NoroPlayer",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "NoroPlayerTests",
            dependencies: ["NoroPlayerLib"],
            path: "Tests/NoroPlayerTests"
        )
    ]
)
