import PackageDescription

let package = Package(
    name: "VaporApp",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/leaf-provider.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/mysql-provider.git", Version(2,0,0, prereleaseIdentifiers: ["beta"])),
    ],
    exclude: [
        "Config",
        "Deploy",
        "Public",
        "Resources",
        "Tests",
        "Database"
    ]
)
