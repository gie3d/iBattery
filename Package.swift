// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iBattery",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "iBattery",
            path: "Sources/iBattery"
        )
    ]
)
