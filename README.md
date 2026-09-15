# XcodeShift

A small native macOS menu-bar utility for switching the system-wide active Xcode installation.

## Features

- Shows the active Xcode version directly in the menu bar.
- Finds Xcode installations using Spotlight plus `/Applications` and `~/Applications` fallbacks.
- Highlights the currently active Xcode.
- One-click switching between installations.
- Uses the standard macOS administrator authentication prompt for `xcode-select --switch`.
- Opens the active Xcode.
- Management window with version, build number, install path, Finder, and Open Xcode actions.
- Runs as a menu-bar utility (`LSUIElement = true`), so it does not live in the Dock.

## Requirements

- macOS 13 or later.
- Xcode 14 or later to build. Newer Xcode versions are recommended.

## Run

1. Open `XcodeShift.xcodeproj` in Xcode.
2. Select the **XcodeShift** scheme.
3. In **Signing & Capabilities**, choose your development team if Xcode asks for one.
4. Ensure **App Sandbox is not enabled** for this target.
5. Run.

The menu bar will display something like `🔨 Xcode 27.0`.

Click another Xcode installation. macOS will request administrator authorization and XcodeShift will invoke:

```sh
/usr/bin/xcode-select --switch /path/to/Xcode.app/Contents/Developer
```

## Why administrator authorization?

`xcode-select --switch` changes the system-wide active developer directory and requires superuser permissions. XcodeShift uses `osascript` with AppleScript's `do shell script ... with administrator privileges` to present the normal macOS authentication UI.

## Possible v2 additions

- Launch at login.
- Favorites / pinning.
- Show the .NET iOS workload's recommended Xcode next to each installation.
- Per-project Xcode selection using `DEVELOPER_DIR` without changing the global Xcode.
- Detect Xcode betas / RCs with badges.
- Automatically flag an Xcode version incompatible with the current .NET iOS workload.
- Replace AppleScript elevation with a dedicated privileged helper for a distributable production build.
