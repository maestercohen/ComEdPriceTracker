// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ComEdPriceTracker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "ComEdPriceTracker", targets: ["ComEdPriceTracker"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ComEdPriceTracker",
            dependencies: [],
            path: ".",
            sources: ["ComEdPriceTracker"]
        )
    ]
)