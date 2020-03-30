// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Smtp",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "Smtp", targets: ["Smtp"]),
        .library(name: "SmtpTests", targets: ["SmtpTests"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0-rc.3.12")),

        // Event-driven network application framework for high performance protocol servers & clients, non-blocking.
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.15.0")),

        // Bindings to OpenSSL-compatible libraries for TLS support in SwiftNIO
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMajor(from: "2.7.1"))
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
