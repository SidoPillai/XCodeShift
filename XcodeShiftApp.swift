import SwiftUI

@main
struct XcodeShiftApp: App {
    @StateObject private var manager = XcodeManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(manager: manager)
                .frame(width: 360)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "hammer.fill")
                Text(manager.activeVersionLabel)
            }
        }
        .menuBarExtraStyle(.window)

        Window("Manage Xcodes", id: "manager") {
            ManagerView(manager: manager)
                .frame(minWidth: 620, minHeight: 440)
        }
        .defaultSize(width: 680, height: 520)
    }
}
