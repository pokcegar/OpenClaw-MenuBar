// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TonyController",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "TonyController",
            targets: ["TonyController"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "TonyController",
            path: "TonyController",
            exclude: ["Info.plist", "Assets.xcassets"],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        ),
    ]
)