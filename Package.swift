// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ComEdPriceTracker",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        .executable(name: "ComEdPriceTracker", targets: ["ComEdPriceTrackerCLI"]),
        .library(name: "ComEdPriceTrackerApp", targets: ["ComEdPriceTrackerApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ComEdPriceTrackerCLI", 
            dependencies: [],
            path: ".",
            sources: ["main.swift"]
        ),
        .target(
            name: "ComEdPriceTrackerApp",
            dependencies: [],
            path: "ComEdPriceTracker",
            exclude: [],
            resources: [.process("Resources")],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ]
        )
    ]
)