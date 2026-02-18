import Foundation
import AppKit

class GatewayManager {
    
    /// 获取 OpenClaw 工作目录
    private var workspacePath: String {
        // 使用用户主目录下的 .openclaw/workspace
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.openclaw/workspace"
    }
    
    /// 检查 Gateway 是否正在运行
    func isGatewayRunning() -> Bool {
        let killTask = Process()
        killTask.launchPath = "/usr/bin/killall"
        killTask.arguments = ["-0", "openclaw-gateway"]
        
        do {
            try killTask.run()
            killTask.waitUntilExit()
            if killTask.terminationStatus == 0 {
                return true
            }
        } catch {
            print("killall 检测失败: \(error)")
        }
        
        let psTask = Process()
        psTask.launchPath = "/bin/ps"
        psTask.arguments = ["-ax", "-o", "command"]
        
        let pipe = Pipe()
        psTask.standardOutput = pipe
        
        do {
            try psTask.run()
            psTask.waitUntilExit()
            
            if let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
                if output.contains("openclaw-gateway") {
                    return true
                }
            }
        } catch {
            print("ps 检测失败: \(error)")
        }
        
        return checkPortResponse()
    }
    
    /// 重启 Gateway
    func restartGateway() {
        let script = restartAppleScript
        runAppleScript(script, action: "重启")
    }
    
    /// 停止 Gateway
    func stopGateway() {
        let script = stopAppleScript
        runAppleScript(script, action: "停止")
    }
    
    /// 启动 Gateway
    func startGateway() {
        let script = startAppleScript
        runAppleScript(script, action: "启动")
    }
    
    // MARK: - AppleScripts
    
    private var startAppleScript: String {
        return """
tell application "Terminal"
	do script "echo '🚀 启动 OpenClaw Gateway...'
PID=$(ps aux | grep 'openclaw-gateway' | grep -v grep | awk '{print $2}' | head -1)
if [ -n \\"$PID\\" ]; then
    echo \\"⚠️ Gateway 已经在运行 (PID: $PID)\\"
    exit 0
fi
echo '📁 切换到工作目录...'
cd \(workspacePath)
echo '🚀 启动 Gateway...'
nohup openclaw gateway > /tmp/openclaw.log 2>&1 &
sleep 2
NEW_PID=$(ps aux | grep 'openclaw-gateway' | grep -v grep | awk '{print $2}' | head -1)
if [ -n \\"$NEW_PID\\" ]; then
    echo \\"✅ Gateway 启动成功！PID: $NEW_PID\\"
else
    echo '❌ Gateway 启动失败，请检查日志: /tmp/openclaw.log'
fi
echo ''
echo '💡 提示: 使用 openclaw status 查看详细状态'"
	activate
end tell
"""
    }
    
    private var stopAppleScript: String {
        return """
tell application "Terminal"
	do script "echo '🛑 正在停止 OpenClaw Gateway...'
PID=$(ps aux | grep 'openclaw-gateway' | grep -v grep | awk '{print $2}' | head -1)
if [ -n \\"$PID\\" ]; then
    echo \\"发现 Gateway (PID: $PID)，正在停止...\\"
    kill $PID 2>/dev/null
    sleep 2
    if ps -p $PID > /dev/null 2>&1; then
        echo '强制终止...'
        kill -9 $PID 2>/dev/null
    fi
    echo '✅ Gateway 已停止'
else
    echo '⚠️ 未发现运行中的 Gateway'
fi"
	activate
end tell
"""
    }
    
    private var restartAppleScript: String {
        return """
tell application "Terminal"
	do script "echo '🔍 检查 OpenClaw Gateway 状态...'
PID=$(ps aux | grep 'openclaw-gateway' | grep -v grep | awk '{print $2}' | head -1)
if [ -n \\"$PID\\" ]; then
    echo \\"🛑 发现 Gateway 正在运行 (PID: $PID)，准备重启...\\"
    kill $PID 2>/dev/null
    sleep 3
    if ps -p $PID > /dev/null 2>&1; then
        echo '⚠️  强制终止...'
        kill -9 $PID 2>/dev/null
        sleep 1
    fi
    echo '✅ 已停止旧进程'
else
    echo '🚀 未发现运行中的 Gateway，准备启动...'
fi
echo '📁 切换到工作目录...'
cd \(workspacePath)
echo '🚀 启动 Gateway...'
nohup openclaw gateway > /tmp/openclaw.log 2>&1 &
sleep 2
NEW_PID=$(ps aux | grep 'openclaw-gateway' | grep -v grep | awk '{print $2}' | head -1)
if [ -n \\"$NEW_PID\\" ]; then
    echo \\"✅ Gateway 启动成功！PID: $NEW_PID\\"
else
    echo '❌ Gateway 启动失败，请检查日志: /tmp/openclaw.log'
fi
echo ''
echo '💡 提示: 使用 openclaw status 查看详细状态'"
	activate
end tell
"""
    }
    
    // MARK: - Execution
    
    private func runAppleScript(_ script: String, action: String) {
        // 方法1: 使用 NSAppleScript（能触发权限请求）
        if let nsScript = NSAppleScript(source: script) {
            var errorInfo: NSDictionary?
            _ = nsScript.executeAndReturnError(&errorInfo)
            
            if let error = errorInfo {
                print("NSAppleScript 错误: \(error)")
                if let errorNumber = error["NSAppleScriptErrorNumber"] as? NSNumber,
                   errorNumber.intValue == -1743 {
                    showPermissionAlert()
                }
                // 失败时尝试 osascript
                runWithOsascript(script, action: action)
            } else {
                print("\(action) 命令已发送")
            }
        } else {
            runWithOsascript(script, action: action)
        }
    }
    
    private func runWithOsascript(_ script: String, action: String) {
        // 方法2: 使用 osascript 命令
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", script]
        
        let errorPipe = Pipe()
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if let errorOutput = String(data: errorData, encoding: .utf8),
               !errorOutput.isEmpty {
                print("osascript 错误: \(errorOutput)")
                if errorOutput.contains("(-1743)") {
                    showPermissionAlert()
                } else {
                    // 其他错误，使用 shell 备选
                    runShellFallback(action: action)
                }
            } else if task.terminationStatus == 0 {
                print("\(action) 命令已发送 (osascript)")
            } else {
                runShellFallback(action: action)
            }
        } catch {
            print("osascript 失败: \(error)")
            runShellFallback(action: action)
        }
    }
    
    private func runShellFallback(action: String) {
        print("使用 shell 备选方案: \(action)")
        
        switch action {
        case "启动":
            let script = "cd \(workspacePath) && nohup openclaw gateway > /tmp/openclaw.log 2>&1 &"
            runShellCommand(script)
        case "停止":
            runShellCommand("killall openclaw-gateway")
        case "重启":
            let script = "pkill openclaw-gateway; sleep 2; cd \(workspacePath) && nohup openclaw gateway > /tmp/openclaw.log 2>&1 &"
            runShellCommand(script)
        default:
            break
        }
    }
    
    private func runShellCommand(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        do {
            try task.run()
        } catch {
            print("Shell 命令失败: \(error)")
        }
    }
    
    private func showPermissionAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "需要自动化权限"
            alert.informativeText = "OpenClaw MenuBar 需要控制 Terminal 的权限。请前往系统设置 > 隐私与安全性 > 自动化，允许 OpenClaw MenuBar 控制 Terminal。"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "打开设置")
            alert.addButton(withTitle: "取消")
            
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!)
            }
        }
    }
    
    private func checkPortResponse() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/nc"
        task.arguments = ["-z", "-G", "2", "127.0.0.1", "18789"]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
}
