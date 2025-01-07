// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let VERSION_PARAM_KIT: PackageDescription.Version = "6.2.0-alpha.1"
let VERSION_COMMON_UI: PackageDescription.Version = "2.0.2"

let package = Package(
    name: "PayUIndia-UPIKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "PayUIndia-Logger",
            targets: ["PayULoggerKit"]
        ),
        .library(
            name: "PayUIndia-Networking",
            targets: ["PayUIndia-NetworkingTarget"]
        ),
        .library(
            name: "PayUIndia-UPICore",
            targets: ["PayUIndia-UPICoreTarget"]
        ),
        .library(
            name: "PayUIndia-UPI",
            targets: ["PayUIndia-UPITarget"]
        )
    ],
    dependencies: [
        .package(name: "PayUIndia-PayUParams", url: "https://github.com/payu-intrepos/payu-params-iOS.git", from: VERSION_PARAM_KIT),
        .package(name: "PayUIndia-CommonUI", url: "https://github.com/payu-intrepos/PayUCommonUI-iOS", from: VERSION_COMMON_UI)
    ],
    targets: [
        .binaryTarget(name: "PayULoggerKit", path: "./Dependencies/PayULoggerKit.xcframework"),
        .binaryTarget(name: "PayUNetworkingKit", path: "./Dependencies/PayUNetworkingKit.xcframework"),
        .binaryTarget(name: "PayUUPICoreKit", path: "./Dependencies/PayUUPICoreKit.xcframework"),
        .binaryTarget(name: "PayUUPIKit", path: "./Dependencies/PayUUPIKit.xcframework"),
        .target(
            name: "PayUIndia-NetworkingTarget",
            dependencies: [
                "PayUNetworkingKit",
                "PayULoggerKit"
            ],
            path: "Wrappers/PayUIndia-NetworkingWrapper"
        ),
        .target(
            name: "PayUIndia-UPICoreTarget",
            dependencies: [
                .product(name: "PayUIndia-PayUParams", package: "PayUIndia-PayUParams"),
                "PayUIndia-NetworkingTarget",
                "PayUUPICoreKit"
            ],
            path: "Wrappers/PayUIndia-UPICoreWrapper"
        ),
        .target(
            name: "PayUIndia-UPITarget",
            dependencies: [
                "PayUUPIKit",
                "PayUIndia-UPICoreTarget"
            ],
            path: "Wrappers/PayUIndia-UPIWrapper"
        )
    ]
)
