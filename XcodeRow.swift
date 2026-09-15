import AppKit
import SwiftUI

struct XcodeRow: View {
    let xcode: XcodeInstallation
    let isActive: Bool
    let isSwitching: Bool
    var compact = false
    var onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: xcode.url.path))
                    .resizable()
                    .interpolation(.high)
                    .frame(width: compact ? 34 : 44, height: compact ? 34 : 44)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 7) {
                        Text("Xcode \(xcode.version)")
                            .font(.system(size: compact ? 13 : 14, weight: .semibold))

                        if isActive {
                            Text("ACTIVE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.tint)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.tint.opacity(0.12), in: Capsule())
                        }
                    }

                    Text("Build \(xcode.build) • \(xcode.name).app")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if !compact {
                        Text(xcode.url.path)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }

                Spacer(minLength: 8)

                if isSwitching {
                    ProgressView()
                        .controlSize(.small)
                } else if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tint)
                } else {
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(compact ? 9 : 12)
            .contentShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isActive ? Color.accentColor.opacity(0.09) : Color.primary.opacity(0.035))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isActive ? Color.accentColor.opacity(0.38) : Color.clear, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isActive || isSwitching)
        .help(isActive ? "Currently selected Xcode" : "Switch to Xcode \(xcode.version)")
    }
}
