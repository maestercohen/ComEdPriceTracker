// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ComEdPriceTracker",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "ComEdPriceTracker", targets: ["ComEdPriceTracker"])
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .executableTarget(
            name: "ComEdPriceTracker",
            dependencies: [],
            path: "ComEdPriceTracker",
            exclude: ["Views", "Models", "Services", "Assets.xcassets", "Info.plist"]
        )
    ]
)