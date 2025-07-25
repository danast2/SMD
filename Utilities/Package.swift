// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "PieChart",
            targets: ["PieChart"]
        ),
    ],
    targets: [
        .target(
            name: "PieChart",
            path: "Sources/PieChart"
        ),
        .testTarget(
            name: "PieChartTests",
            dependencies: ["PieChart"],
            path: "Tests/PieChartTests"
        )
    ]
)
