// swift-tools-version:5.6
//
//  Copyright © 2022 Surprise HR, Inc. All rights reserved.
//

import PackageDescription

let package = Package(
	name: "Drift",
	platforms: [
		.iOS(.v15)
	],
	products: [
		.library(
			name: "Drift",
			targets: ["Drift"]),
	],
	dependencies: [
		.package(url: "https://github.com/daltoniam/Starscream.git", exact: "3.1.1"),
		.package(url: "https://github.com/Alamofire/AlamofireImage.git", .upToNextMajor(from: "4.0.0")),
	],
	targets: [
		.target(
			name: "Drift",
			dependencies: [
				"Starscream",
				"AlamofireImage",
			],
			path: "Drift",
			exclude: [
				"Info.plist", "Birdsong/README.md"
			]
		),
		.testTarget(
			name: "DriftTests",
			dependencies: ["Drift"],
			path: "DriftTests",
			exclude: [
				"Info.plist",
			]
		),
	]
)
