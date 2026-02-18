# OpenClaw-MenuBar

[中文](README.zh.md) | English

A macOS Menu Bar controller for OpenClaw Gateway, featuring automatic iMessage full disk access permission handling.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- 🦞 **Menu Bar Icon** - Clean status bar interface with color-coded status indicators
- 🚀 **Gateway Control** - Start/Stop/Restart OpenClaw Gateway with one click
- 🔐 **iMessage Support** - Ensures Gateway runs with full disk access permissions for iMessage functionality
- 🔄 **Auto-start** - Optionally auto-start Gateway when the controller launches
- 📊 **Dashboard Access** - Quick access to OpenClaw Dashboard
- ⚡ **Real-time Status** - Automatic status detection every 5 seconds

## Why This Controller?

When OpenClaw Gateway is started via LaunchAgent or directly, it may not have full disk access permissions, causing iMessage functionality to fail. This controller solves this by:

1. Using Terminal.app (which already has full disk access) to launch Gateway
2. Providing a convenient Menu Bar interface for daily use
3. Automatically handling permission inheritance

```
Tony Controller.app → Terminal.app (with full disk access) → Gateway ✅
```

## Installation

### Method 1: Build from Source

```bash
git clone https://github.com/pockegar/OpenClaw-MenuBar.git
cd OpenClaw-MenuBar
swift build -c release
```

The built app will be at `.build/release/TonyController`.

### Method 2: Download Release

Download the latest release from [Releases](https://github.com/pockegar/OpenClaw-MenuBar/releases).

## Usage

1. **First Launch**: Grant "Automation" permission when prompted (System Settings → Privacy & Security → Automation)
2. **Grant Full Disk Access to Terminal**: Ensure Terminal.app has full disk access
3. **Click the 🦞 icon** in the Menu Bar to access controls

### Menu Options

| Option | Description |
|--------|-------------|
| Start Gateway | Launch OpenClaw Gateway in Terminal |
| Stop Gateway | Stop the running Gateway |
| Restart Gateway | Stop and restart Gateway |
| Open Dashboard | Open OpenClaw web dashboard |
| Auto-start Gateway | Toggle automatic start on launch |

## Requirements

- macOS 12.0+
- OpenClaw installed (`openclaw` command available)
- Terminal.app with Full Disk Access permission

## Architecture

```
TonyController/
├── TonyControllerApp.swift      # App entry point
├── MenuBarController.swift      # Menu bar UI and interactions
├── GatewayManager.swift         # Gateway control logic
└── SettingsManager.swift        # User preferences
```

## Permissions

The app requires the following permissions:

1. **Automation** - Control Terminal.app
2. **Accessibility** (optional) - For enhanced UI interactions

To grant permissions:
- System Settings → Privacy & Security → Automation → Enable "Tony Controller"

## Troubleshooting

### No Terminal Window Appears
- Check if Terminal.app has Full Disk Access
- Verify "Automation" permission is granted to Tony Controller
- Check Console.app for error messages

### iMessage Not Working
- Ensure Gateway was started through Tony Controller (not directly)
- Verify Terminal.app has Full Disk Access permission
- Restart Gateway using the controller

## Contributing

Pull requests are welcome! For major changes, please open an issue first.

## License

[MIT](LICENSE)

## Acknowledgments

- Built for [OpenClaw](https://github.com/openclaw/openclaw)
- Inspired by the need for reliable iMessage gateway control
