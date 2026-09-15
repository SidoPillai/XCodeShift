import AppKit
import SwiftUI

struct ManagerView: View {
    @ObservedObject var manager: XcodeManager

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Installed Xcodes")
                        .font(.title2.weight(.semibold))
                    Text("Select an installation to make it the system-wide active developer directory.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    manager.refresh()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            .padding(18)

            Divider()

            if manager.installations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "hammer")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                    Text("No Xcode installations found")
                        .font(.headline)
                    Text("XcodeShift checks Spotlight, /Applications, and ~/Applications.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(manager.installations) { xcode in
                            XcodeRow(
                                xcode: xcode,
                                isActive: manager.isActive(xcode),
                                isSwitching: manager.switchingPath == xcode.url.path
                            ) {
                                manager.switchTo(xcode)
                            }
                            .contextMenu {
                                Button("Open Xcode") {
                                    manager.open(xcode)
                                }

                                Button("Show in Finder") {
                                    NSWorkspace.shared.activateFileViewerSelecting([xcode.url])
                                }
                            }
                        }
                    }
                    .padding(18)
                }
            }

            Divider()

            HStack {
                Image(systemName: "info.circle")
                Text("Switching uses macOS administrator authentication because xcode-select --switch requires superuser privileges.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(14)
        }
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
}
