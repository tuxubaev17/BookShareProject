// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Griffon_ios_spm",
    
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Griffon_ios_spm",
            targets: ["Griffon_ios_spm"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "14.0.0")),
        .package(name: "KeychainSwift", url: "https://github.com/evgenyneu/keychain-swift.git", .upToNextMajor(from: "19.0.0"))
        //.package(name: "KeychainSwift",url: "https://github.com/evgenyneu/keychain-swift.git", .branch("master")),
    ],
    targets: [
        .target(name: "Griffon_ios_spm", dependencies: ["Moya",
            .product(name: "KeychainSwift", package: "KeychainSwift")]),
        .testTarget(name: "Griffon_ios_spmTests", dependencies: ["Griffon_ios_spm"]),
    ]
)
