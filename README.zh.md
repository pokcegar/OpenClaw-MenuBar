# OpenClaw-MenuBar

中文 | [English](README.md)

OpenClaw Gateway 的 macOS 菜单栏控制器，专门解决 iMessage 完全磁盘访问权限问题。

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 功能特性

- 🦞 **菜单栏图标** - 简洁的状态栏界面，彩色状态指示器
- 🚀 **Gateway 控制** - 一键启动/停止/重启 OpenClaw Gateway
- 🔐 **iMessage 支持** - 确保 Gateway 以完全磁盘访问权限运行，支持 iMessage 功能
- 🔄 **自动启动** - 启动控制器时自动启动 Gateway
- 📊 **Dashboard 访问** - 快速访问 OpenClaw 网页控制台
- ⚡ **实时状态** - 每 5 秒自动检测 Gateway 状态

## 为什么需要这个控制器？

当 OpenClaw Gateway 通过 LaunchAgent 或直接启动时，可能没有完全磁盘访问权限，导致 iMessage 功能无法工作。本控制器通过以下方式解决：

1. 使用已拥有完全磁盘访问权限的 Terminal.app 来启动 Gateway
2. 提供便捷的菜单栏界面供日常使用
3. 自动处理权限继承

```
Tony Controller.app → Terminal.app（有完全磁盘访问权限）→ Gateway ✅
```

## 安装

### 方式一：从源码构建

```bash
git clone https://github.com/pockegar/OpenClaw-MenuBar.git
cd OpenClaw-MenuBar
swift build -c release
```

构建好的应用位于 `.build/release/TonyController`。

### 方式二：下载 Release

从 [Releases](https://github.com/pockegar/OpenClaw-MenuBar/releases) 下载最新版本。

## 使用方法

1. **首次启动**：根据提示授予"自动化"权限（系统设置 → 隐私与安全性 → 自动化）
2. **授予 Terminal 完全磁盘访问权限**：确保 Terminal.app 有完全磁盘访问权限
3. **点击菜单栏的 🦞 图标** 访问控制选项

### 菜单选项

| 选项 | 说明 |
|------|------|
| 启动 Gateway | 在 Terminal 中启动 OpenClaw Gateway |
| 停止 Gateway | 停止运行的 Gateway |
| 重启 Gateway | 停止并重新启动 Gateway |
| 打开 Dashboard | 打开 OpenClaw 网页控制台 |
| 启动时自动开启 Gateway | 切换启动时自动启动功能 |

## 系统要求

- macOS 12.0+
- 已安装 OpenClaw（`openclaw` 命令可用）
- Terminal.app 拥有完全磁盘访问权限

## 项目结构

```
TonyController/
├── TonyControllerApp.swift      # 应用入口
├── MenuBarController.swift      # 菜单栏 UI 和交互
├── GatewayManager.swift         # Gateway 控制逻辑
└── SettingsManager.swift        # 用户偏好设置
```

## 权限说明

本应用需要以下权限：

1. **自动化** - 控制 Terminal.app
2. **辅助功能**（可选）- 增强 UI 交互

授予权限：
- 系统设置 → 隐私与安全性 → 自动化 → 启用"Tony Controller"

## 常见问题

### Terminal 窗口没有弹出
- 检查 Terminal.app 是否有完全磁盘访问权限
- 确认"Tony Controller"的"自动化"权限已开启
- 查看 Console.app 中的错误信息

### iMessage 无法正常工作
- 确保 Gateway 是通过 Tony Controller 启动的（不是直接启动）
- 验证 Terminal.app 有完全磁盘访问权限
- 使用控制器重启 Gateway

## 参与贡献

欢迎提交 Pull Request！重大改动请先开 Issue 讨论。

## 许可证

[MIT](LICENSE)

## 致谢

- 为 [OpenClaw](https://github.com/openclaw/openclaw) 构建
- 灵感来源于对可靠 iMessage Gateway 控制的需求
