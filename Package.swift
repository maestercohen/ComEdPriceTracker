// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ComEdPriceTracker",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .executable(name: "ComEdPriceTracker", targets: ["ComEdPriceTracker"]),
        .library(name: "ComEdPriceTrackerWidget", targets: ["ComEdPriceTrackerWidget"])
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .executableTarget(
            name: "ComEdPriceTracker",
            dependencies: [],
            path: "ComEdPriceTracker"
        ),
        .target(
            name: "ComEdPriceTrackerWidget",
            dependencies: [],
            path: "ComEdPriceTrackerWidget"
        )
    ]
)