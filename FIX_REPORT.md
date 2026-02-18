# Tony Controller Gateway 修复报告

## 问题分析

1. **NSAppleScript 权限问题**：直接使用 `NSAppleScript` 可能因为 macOS 自动化权限限制而失败
2. **字符串转义问题**：多行 shell 脚本中的特殊字符（$、"、\\）需要正确转义
3. **多行字符串缩进**：Swift 多行字符串 `"""` 对缩进有严格要求

## 修复方案

### 主要改动

1. **重构代码结构**：
   - 将 shell 脚本提取为单独的 computed properties (`startScript`, `stopScript`, `restartScript`)
   - 简化了 `executeInTerminal` 方法，统一处理脚本转义

2. **改进执行方式**：
   - **主要方法**：使用 `osascript` 命令行工具执行 AppleScript（更可靠）
   - **备选方法1**：使用 `NSAppleScript` 作为备选
   - **备选方法2**：直接通过 shell 执行（如果 AppleScript 失败）

3. **完善错误处理**：
   - 捕获并检查 osascript 的错误输出
   - 检测权限错误（-1743）并提示用户
   - 自动回退到备选方案

4. **改进字符串转义**：
   ```swift
   let escapedScript = shellScript
       .replacingOccurrences(of: "\\", with: "\\\\")
       .replacingOccurrences(of: "\"", with: "\\\"")
       .replacingOccurrences(of: "$", with: "\\$")
   ```

### 修复后的执行流程

```
用户点击启动/停止/重启
    ↓
调用 executeInTerminal(shellScript, action)
    ↓
转义 shell 脚本中的特殊字符
    ↓
构建 AppleScript: tell application "Terminal"...
    ↓
executeAppleScript(script, fallbackAction)
    ↓
方法1: 使用 osascript 命令行工具执行
    ├─ 成功 → Terminal 弹出并执行
    └─ 失败（权限错误）
        ↓
    方法2: 使用 NSAppleScript 执行
        ├─ 成功 → Terminal 弹出并执行
        └─ 失败 → 显示权限提示
            ↓
    方法3: 使用 shell 直接执行（无 Terminal 窗口）
```

### 权限处理

当检测到权限错误时（错误码 -1743），会显示提示框引导用户到：
系统设置 → 隐私与安全性 → 自动化 → 允许 Tony Controller 控制 Terminal

## 测试建议

1. 首次运行时，系统会提示是否允许 Tony Controller 控制 Terminal，请点击"允许"
2. 如果没有提示或之前拒绝过，需要手动到系统设置中开启权限
3. 点击启动/重启/停止按钮时，应该能看到 Terminal 窗口弹出并显示执行过程

## 构建说明

```bash
# 调试版本
swift build

# 发布版本
swift build -c release

# 或使用 Xcode 构建 app bundle
xcodebuild -project TonyController.xcodeproj -scheme TonyController -configuration Release
```

## 文件位置

修复后的文件：`/Users/zzy/Desktop/TonyControllerProject/TonyController/GatewayManager.swift`
