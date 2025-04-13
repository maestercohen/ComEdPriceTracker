// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ComEdPriceTracker",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v15)
    ],
    products: [
        // Main app as a library product (for iOS app)
        .library(
            name: "ComEdPriceTracker",
            targets: ["ComEdPriceTracker"]
        ),
        // CLI tool as a separate executable product
        .executable(
            name: "ComEdPriceTrackerCLI",
            targets: ["ComEdPriceTrackerCLI"]
        )
    ],
    dependencies: [],
    targets: [
        // Main app target
        .target(
            name: "ComEdPriceTracker",
            dependencies: [],
            path: "ComEdPriceTracker",
            resources: [.process("Resources")]
        ),
        // CLI tool target in a separate directory
        .executableTarget(
            name: "ComEdPriceTrackerCLI",
            dependencies: [],
            path: "CLI"
        )
    ]
)