// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "smtp",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "SMTP", targets: ["SMTP"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.1")),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.16.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMajor(from: "2.7.1"))
    ],
    targets: [
        .target(name: "SMTP", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "Vapor", package: "vapor")
        ], path: "Sources"),
        .testTarget(name: "SMTPTests", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "Vapor", package: "vapor"),
            .target(name: "SMTP")
        ], path: "Tests")
    ]
)
