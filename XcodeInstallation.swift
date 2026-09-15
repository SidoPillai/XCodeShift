import Foundation

struct XcodeInstallation: Identifiable, Hashable, Sendable {
    let url: URL
    let version: String
    let build: String

    var id: String { url.path }

    var name: String {
        url.deletingPathExtension().lastPathComponent
    }

    var developerDirectory: URL {
        url.appendingPathComponent("Contents/Developer", isDirectory: true)
    }

    static func load(from url: URL) -> XcodeInstallation? {
        guard
            url.pathExtension == "app",
            let bundle = Bundle(url: url),
            bundle.bundleIdentifier == "com.apple.dt.Xcode"
        else {
            return nil
        }

        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"

        let buildFromBundle = bundle.object(forInfoDictionaryKey: "DTXcodeBuild") as? String
        let versionPlistURL = url.appendingPathComponent("Contents/version.plist")
        let versionPlist = NSDictionary(contentsOf: versionPlistURL)
        let buildFromVersionPlist = versionPlist?["ProductBuildVersion"] as? String

        return XcodeInstallation(
            url: url,
            version: version,
            build: buildFromBundle ?? buildFromVersionPlist ?? "Unknown"
        )
    }
}
