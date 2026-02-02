// swift-tools-version:6.2
import Foundation
import PackageDescription

let useLocalDeps: Bool = {
  guard let raw = ProcessInfo.processInfo.environment["SPM_USE_LOCAL_DEPS"] else { return false }
  let v = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  return v == "1" || v == "true" || v == "yes"
}()

func localOrRemote(name: String, path: String, url: String, from version: Version) -> Package.Dependency {
  if useLocalDeps { return .package(name: name, path: path) }
  return .package(url: url, from: version)
}

let sharedSwiftSettings: [SwiftSetting] =
  useLocalDeps ? [.unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=10"])] : []

let package = Package(
  name: "WrkstrmNetworking",
  platforms: [
    .iOS(.v16),
    .macOS(.v14),
    .macCatalyst(.v15),
    .tvOS(.v16),
    .visionOS(.v1),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "WrkstrmNetworking", targets: ["WrkstrmNetworking"])
  ],
  dependencies: [
    localOrRemote(
      name: "wrkstrm-foundation",
      path: "../wrkstrm-foundation",
      url: "https://github.com/wrkstrm/wrkstrm-foundation.git",
      from: "3.0.0"),
    localOrRemote(
      name: "common-log",
      path: "../../../../../../../swift-universal/public/spm/universal/domain/system/common-log",
      url: "https://github.com/swift-universal/common-log.git",
      from: "3.0.0"),
    localOrRemote(
      name: "wrkstrm-main",
      path: "../wrkstrm-main",
      url: "https://github.com/wrkstrm/wrkstrm-main.git",
      from: "3.0.0"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0")
  ],
  targets: [
    .target(
      name: "WrkstrmNetworking",
      dependencies: [
        .product(name: "WrkstrmFoundation", package: "wrkstrm-foundation"),
        .product(name: "CommonLog", package: "common-log"),
        .product(name: "WrkstrmMain", package: "wrkstrm-main")
      ],
      path: "sources/wrkstrm-networking",
      swiftSettings: sharedSwiftSettings,
    ),
    .testTarget(
      name: "WrkstrmNetworkingTests",
      dependencies: ["WrkstrmNetworking"],
      path: "tests/wrkstrm-networking-tests",
      swiftSettings: sharedSwiftSettings,
    ),
  ]
)
