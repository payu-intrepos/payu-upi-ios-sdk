// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayUIndia-UPIKit",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PayUIndia-Logger",
            targets: ["PayULoggerKit"]),
        .library(
            name: "PayUIndia-Networking",
            targets: ["PayUIndia-NetworkingTarget"]),
        .library(
            name: "PayUIndia-UPICore",
            targets: ["PayUIndia-UPICoreTarget"]),
        .library(
            name: "PayUIndia-UPI",
            targets: ["PayUIndia-UPITarget"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PayUIndia-PayUParams",url: "https://github.com/payu-intrepos/payu-params-iOS.git", from: "4.0.0"),
    ],
    targets: [
        .binaryTarget(name: "PayULoggerKit", path: "./Dependencies/PayULoggerKit.xcframework"),
        .binaryTarget(name: "PayUNetworkingKit", path: "./Dependencies/PayUNetworkingKit.xcframework"),
        .binaryTarget(name: "PayUUPICoreKit", path: "./Dependencies/PayUUPICoreKit.xcframework"),
        .binaryTarget(name: "PayUUPIKit", path: "./Dependencies/PayUUPIKit.xcframework"),
        .binaryTarget(name: "Starscream", path: "./Dependencies/Starscream.xcframework"),
        .binaryTarget(name: "SocketIO", path: "./Dependencies/SocketIO.xcframework"),
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
                "SocketIOTarget",
                "PayUIndia-NetworkingTarget",
                "PayUUPICoreKit"
            ],
            path: "Wrappers/PayUIndia-UPICoreWrapper"
        ),
        .target(
            name: "SocketIOTarget",
            dependencies: [
                "SocketIO",
                "Starscream"
            ],
            path: "Wrappers/SocketIOWrapper"
        ),
        .target(
            name: "PayUIndia-UPITarget",
            dependencies: [
                "PayUUPIKit",
                "PayUUPICoreKit"
            ],
            path: "Wrappers/PayUIndia-UPIWrapper"
        ),
    ]
)
