// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "TweaKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "TweaKit", targets: ["TweaKit"])
    ],
    targets: [
        .target(name: "TweaKit", path: "Sources", exclude: ["Info.plist"])
    ]
)
