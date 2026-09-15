import AppKit
import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var manager: XcodeManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("XcodeShift")
                        .font(.headline)
                    Text(activeSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    manager.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .help("Refresh installed Xcodes")
            }

            Divider()

            if manager.installations.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "hammer")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("No Xcode installations found")
                        .font(.headline)
                    Text("Install Xcode in /Applications, ~/Applications, or another Spotlight-indexed location.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 160)
            } else {
                ScrollView {
                    LazyVStack(spacing: 7) {
                        ForEach(manager.installations) { xcode in
                            XcodeRow(
                                xcode: xcode,
                                isActive: manager.isActive(xcode),
                                isSwitching: manager.switchingPath == xcode.url.path,
                                compact: true
                            ) {
                                manager.switchTo(xcode)
                            }
                        }
                    }
                }
                .frame(maxHeight: 330)
            }

            Divider()

            HStack {
                Button {
                    manager.openActiveXcode()
                } label: {
                    Label("Open Xcode", systemImage: "arrow.up.forward.app")
                }
                .disabled(manager.activeInstallation == nil)

                Spacer()

                Button {
                    openWindow(id: "manager")
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Label("Manage…", systemImage: "macwindow")
                }

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("Quit", systemImage: "power")
                }
            }
            .controlSize(.small)
        }
        .padding(14)
        .alert(
            "Couldn’t switch Xcode",
            isPresented: Binding(
                get: { manager.errorMessage != nil },
                set: { if !$0 { manager.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                manager.errorMessage = nil
            }
        } message: {
            Text(manager.errorMessage ?? "Unknown error")
        }
    }

    private var activeSubtitle: String {
        guard let active = manager.activeInstallation else {
            return manager.activeDeveloperPath.isEmpty
                ? "No active developer directory"
                : manager.activeDeveloperPath
        }

        return "Active: Xcode \(active.version) (\(active.build))"
    }
}
