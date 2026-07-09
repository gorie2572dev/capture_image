// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CaptureImage",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CaptureImage", targets: ["CaptureImage"])
    ],
    targets: [
        .executableTarget(
            name: "CaptureImage",
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "CaptureImageTests",
            dependencies: ["CaptureImage"]
        )
    ]
)
