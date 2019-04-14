// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Smtp",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "Smtp", targets: ["Smtp"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "3.2.0")),

        // Event-driven network application framework for high performance protocol servers & clients, non-blocking.
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "1.13.0")),

        // Bindings to OpenSSL-compatible libraries for TLS support in SwiftNIO
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMajor(from: "1.0.1"))
    ],
    targets: [
        .target(name: "Smtp", dependencies: ["NIO", "NIOOpenSSL", "Vapor"]),
        .testTarget(name: "SmtpTests", dependencies: ["Smtp", "NIO", "NIOOpenSSL", "Vapor"]),
    ]
)
