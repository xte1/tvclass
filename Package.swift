// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tvclass",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "Tvclass",
            targets: ["Tvclass"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Tvclass",
            path: "Tvclass"
        )
    ]
)
