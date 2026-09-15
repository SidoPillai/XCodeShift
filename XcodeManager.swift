import AppKit
import Foundation

@MainActor
final class XcodeManager: ObservableObject {
    @Published private(set) var installations: [XcodeInstallation] = []
    @Published private(set) var activeDeveloperPath = ""
    @Published private(set) var switchingPath: String?
    @Published var errorMessage: String?

    var activeInstallation: XcodeInstallation? {
        installations.first(where: isActive)
    }

    var activeVersionLabel: String {
        activeInstallation.map { "Xcode \($0.version)" } ?? "Xcode"
    }

    init() {
        refresh()
    }

    func refresh() {
        activeDeveloperPath = Self.currentDeveloperPath()
        installations = Self.discoverXcodes()
    }

    func isActive(_ xcode: XcodeInstallation) -> Bool {
        normalize(xcode.developerDirectory.path) == normalize(activeDeveloperPath)
    }

    func switchTo(_ xcode: XcodeInstallation) {
        guard !isActive(xcode), switchingPath == nil else { return }

        let developerPath = xcode.developerDirectory.path
        switchingPath = xcode.url.path
        errorMessage = nil

        Task {
            do {
                try await Task.detached(priority: .userInitiated) {
                    try Self.switchDeveloperDirectory(to: developerPath)
                }.value

                refresh()
            } catch {
                errorMessage = error.localizedDescription
            }

            switchingPath = nil
        }
    }

    func open(_ xcode: XcodeInstallation) {
        NSWorkspace.shared.open(xcode.url)
    }

    func openActiveXcode() {
        guard let activeInstallation else { return }
        open(activeInstallation)
    }

    // MARK: - Xcode discovery

    private static func discoverXcodes() -> [XcodeInstallation] {
        var urls = Set<URL>()

        // Spotlight catches renamed installs and Xcodes stored outside /Applications.
        if let result = try? ProcessRunner.run(
            executable: "/usr/bin/mdfind",
            arguments: ["kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'"]
        ) {
            result.output
                .split(separator: "\n")
                .map { URL(fileURLWithPath: String($0)) }
                .forEach { urls.insert($0.standardizedFileURL) }
        }

        // Deterministic fallback for the two most common install locations.
        [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true)
        ].forEach { directory in
            guard let contents = try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { return }

            contents
                .filter { $0.pathExtension == "app" }
                .forEach { urls.insert($0.standardizedFileURL) }
        }

        return urls
            .compactMap(XcodeInstallation.load)
            .sorted { lhs, rhs in
                let versionOrder = lhs.version.compare(rhs.version, options: .numeric)
                if versionOrder == .orderedSame {
                    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                }
                return versionOrder == .orderedDescending
            }
    }

    private static func currentDeveloperPath() -> String {
        guard let result = try? ProcessRunner.run(
            executable: "/usr/bin/xcode-select",
            arguments: ["--print-path"]
        ) else {
            return ""
        }

        return result.output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Privileged switching

    private nonisolated static func switchDeveloperDirectory(to developerPath: String) throws {
        let command = "/usr/bin/xcode-select --switch \(shellQuote(developerPath))"
        let escapedCommand = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = "do shell script \"\(escapedCommand)\" with administrator privileges"

        _ = try ProcessRunner.run(
            executable: "/usr/bin/osascript",
            arguments: ["-e", script]
        )
    }

    private nonisolated static func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    private func normalize(_ path: String) -> String {
        guard !path.isEmpty else { return "" }
        return URL(fileURLWithPath: path)
            .resolvingSymlinksInPath()
            .standardizedFileURL
            .path
    }
}
