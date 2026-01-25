// swift-tools-version:6.2.1
// The swift-tools-version declares the minimum version of Swift required to build this package

import PackageDescription

let package = Package(
    name: "Smtp",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "Smtp", targets: ["Smtp"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.121.1")),
        
        // Event-driven network application framework for high performance protocol servers & clients, non-blocking
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.93.0")),
        
        // Bindings to OpenSSL-compatible libraries for TLS support in SwiftNIO
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMajor(from: "2.36.0"))
    ],
    targets: [
        .target(name: "Smtp", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "Vapor", package: "vapor")
        ]),
        .testTarget(name: "SmtpTests", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "Vapor", package: "vapor"),
            .target(name: "Smtp")
        ])
    ]
)
