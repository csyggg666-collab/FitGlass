// swift-tools-version: 5.9
import PackageDescription

// Pure-Foundation package: no Apple-only frameworks, so `swift test` runs on
// macOS, Linux, and Windows. The iOS app consumes it as a local SPM dependency.
let package = Package(
    name: "PlanParsingKit",
    products: [
        .library(name: "PlanParsingKit", targets: ["PlanParsingKit"]),
    ],
    targets: [
        .target(name: "PlanParsingKit"),
        .testTarget(
            name: "PlanParsingKitTests",
            dependencies: ["PlanParsingKit"]
        ),
    ]
)
