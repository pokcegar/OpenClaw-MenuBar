# Tony Controller MVP 开发计划

## 项目信息
- **名称**: Tony Controller
- **位置**: /Users/zzy/Desktop/TonyControllerProject
- **平台**: macOS Menu Bar App
- **语言**: Swift + SwiftUI

## 功能需求（MVP）

### 1. 状态栏基础
- [ ] 状态栏图标：🦞 龙虾
- [ ] 点击展开菜单
- [ ] 显示两行状态：Gateway 状态 + iMessage 状态

### 2. 状态检测
- [ ] 检查 Gateway 进程是否存在（pgrep）
- [ ] 检查端口 18789 是否响应（可选）
- [ ] 更新图标颜色：🟢运行/🔴停止

### 3. 核心功能：重启 Gateway
- [ ] 内嵌 AppleScript
- [ ] 调用 Terminal 执行：
  - pkill -f "openclaw gateway"
  - sleep 2
  - cd /Users/zzy/.openclaw/workspace
  - nohup openclaw gateway > /tmp/openclaw.log 2>&1 &
- [ ] 处理权限请求（控制 Terminal）

### 4. 辅助功能
- [ ] 打开 Dashboard 按钮（浏览器打开 127.0.0.1:18789）
- [ ] 退出按钮

## 技术实现

### 文件结构
```
TonyController/
├── TonyController/
│   ├── TonyControllerApp.swift
│   ├── MenuBarController.swift
│   ├── GatewayManager.swift
│   └── Assets.xcassets/
└── TonyController.xcodeproj
```

### 核心类
1. **TonyControllerApp**: App 入口
2. **MenuBarController**: 状态栏控制、菜单UI
3. **GatewayManager**: 状态检测、重启逻辑（AppleScript）

### 关键代码片段
```swift
// 重启 Gateway（AppleScript）
func restartGateway() {
    let script = """
    tell application "Terminal"
        do script "pkill -f 'openclaw gateway'; sleep 2; cd /Users/zzy/.openclaw/workspace && nohup openclaw gateway > /tmp/openclaw.log 2>&1 &"
        activate
    end tell
    """
    // 执行 AppleScript...
}

// 检查状态
func checkStatus() -> Bool {
    let task = Process()
    task.launchPath = "/usr/bin/pgrep"
    task.arguments = ["-f", "openclaw gateway"]
    // 返回进程是否存在...
}
```

## 验收标准

1. 双击运行 App，状态栏出现 🦞 图标
2. 点击图标显示菜单，显示当前 Gateway 状态
3. 点击"重启 Gateway"，Terminal 打开并执行重启命令
4. 重启后状态更新为 🟢
5. 点击"打开 Dashboard"，浏览器打开 127.0.0.1:18789

## 注意事项

1. **权限**: 首次运行会请求"控制 Terminal"权限，用户需要允许
2. **图标**: 使用系统 SF Symbols 或在线找龙虾图标
3. **测试**: 在干净环境测试（关闭现有 Gateway）

## 开发时间
预估 2 小时
