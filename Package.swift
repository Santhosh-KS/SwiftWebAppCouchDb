// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftWebAppCouchDb",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.9.1")),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.9.0")),
        .package(name: "KituraStencil", url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", .upToNextMinor(from: "1.11.1")),
        .package(name: "Kitura-CouchDB", url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", .upToNextMinor(from: "3.2.0")),
        //.package(name: "Kitura-net", url: "https://github.com/IBM-Swift/Kitura-net.git", .upToNextMinor(from:"2.4.0"))
    ],
    targets: [
        .target(
            name: "SwiftWebAppCouchDb",
            dependencies: ["Kitura" , "HeliumLogger", "KituraStencil",
             //.product(name: "KituraNet", package: "Kitura-net"),
             .product(name: "CouchDB", package: "Kitura-CouchDB")]),
        .testTarget(
            name: "SwiftWebAppCouchDbTests",
            dependencies: ["SwiftWebAppCouchDb"]),
    ]
)
