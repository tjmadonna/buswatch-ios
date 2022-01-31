// swift-tools-version:5.2
import PackageDescription

let packageName = "BusWatch" // <-- Change this to yours

let package = Package(
  name: "BusWatch",
  // platforms: [.iOS("9.0")],
  products: [
    .library(name: packageName, targets: [packageName])
  ],
  targets: [
    .target(
      name: packageName,
      path: packageName
    )
  ])
