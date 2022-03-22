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
            targets: ["PayUIndia-Logger"]),
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
//        .package(name: "SocketIO", url: "https://github.com/ShubhGar/socket.io-client-swift.git", .exact("18.0.0"))

        .package(name: "PayUIndia-PayUParams",url: "https://github.com/payu-intrepos/payu-params-iOS.git", from: "3.2.0"),

        
    ],
    targets: [
        .binaryTarget(name: "PayUIndia-Logger", path: "./Dependencies/PayULoggerKit.xcframework"),
        .binaryTarget(name: "PayUIndia-Networking", path: "./Dependencies/PayUNetworkingKit.xcframework"),
        .binaryTarget(name: "PayUIndia-UPICore", path: "./Dependencies/PayUUPICoreKit.xcframework"),
        .binaryTarget(name: "PayUIndia-UPI", path: "./Dependencies/PayUUPIKit.xcframework"),
        .binaryTarget(name: "Starscream", path: "./Dependencies/Starscream.xcframework"),
        .binaryTarget(name: "SocketIO", path: "./Dependencies/SocketIO.xcframework"),
            .target(
                name: "PayUIndia-NetworkingTarget",
                dependencies: [
                    .target(name: "PayUIndia-Networking", condition: .when(platforms: [.iOS])),
                    "PayUIndia-Logger"
                  
                ],
                path: "Wrappers/PayUIndia-NetworkingWrapper"
            ),
        .target(
            name: "PayUIndia-UPICoreTarget",
            dependencies: [
                .target(name: "PayUIndia-UPICore", condition: .when(platforms: [.iOS])),
                .product(name: "PayUIndia-PayUParams", package: "PayUIndia-PayUParams"),
                "SocketIO",
                "PayUIndia-Networking",
            ],
            path: "Wrappers/PayUIndia-UPICoreWrapper"
        ),
        .target(
            name: "SocketIOTarget",
            dependencies: [
                .target(name: "SocketIO", condition: .when(platforms: [.iOS])),
                "Starscream"
            ],
            path: "Wrappers/SocketIOWrapper"
        ),
        .target(
            name: "PayUIndia-UPITarget",
            dependencies: [
                .target(name: "PayUIndia-UPI", condition: .when(platforms: [.iOS])),
                "PayUIndia-UPICore"
            ],
            path: "Wrappers/PayUIndia-UPIWrapper"
        ),
    ]
)
