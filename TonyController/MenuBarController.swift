import SwiftUI
import AppKit

class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem!
    private var gatewayManager: GatewayManager!
    private var statusCheckTimer: Timer?
    
    @Published var gatewayRunning: Bool = false
    
    init() {
        gatewayManager = GatewayManager()
        
        // 创建状态栏图标（使用系统共享实例）
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // 设置点击动作
            button.action = #selector(showMenu)
            button.target = self
            // 初始图标将在 checkStatus() 中设置
        }
        
        // 初始检查状态
        checkStatus()
        
        // 检查是否需要自动启动 Gateway
        autoStartGatewayIfNeeded()
        
        // 定时检查状态（每5秒）
        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkStatus()
        }
    }
    
    /// 如果需要，自动启动 Gateway
    private func autoStartGatewayIfNeeded() {
        guard SettingsManager.shared.autoStartGateway else {
            print("自动启动 Gateway 已禁用")
            return
        }
        
        // 检查 Gateway 是否已在运行
        if !gatewayManager.isGatewayRunning() {
            print("Controller 启动时自动启动 Gateway...")
            gatewayManager.startGateway()
            // 5秒后检查状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.checkStatus()
            }
        } else {
            print("Gateway 已在运行，跳过自动启动")
        }
    }
    
    @objc func showMenu() {
        // 创建菜单
        let menu = NSMenu()
        
        // 标题项（不可点击）
        let titleItem = NSMenuItem()
        titleItem.title = "🦞 OpenClaw MenuBar"
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 状态显示项
        let statusItem = NSMenuItem()
        statusItem.title = gatewayRunning ? "Gateway: 运行中 ✅" : "Gateway: 已停止 ❌"
        statusItem.isEnabled = false
        menu.addItem(statusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 根据状态显示不同的操作按钮
        if gatewayRunning {
            // Gateway 运行中：显示停止按钮
            let stopItem = NSMenuItem(
                title: "停止 Gateway",
                action: #selector(stopGateway),
                keyEquivalent: ""
            )
            stopItem.target = self
            menu.addItem(stopItem)
            
            // 重启按钮
            let restartItem = NSMenuItem(
                title: "重启 Gateway",
                action: #selector(restartGateway),
                keyEquivalent: ""
            )
            restartItem.target = self
            menu.addItem(restartItem)
        } else {
            // Gateway 已停止：显示启动按钮
            let startItem = NSMenuItem(
                title: "启动 Gateway",
                action: #selector(startGateway),
                keyEquivalent: ""
            )
            startItem.target = self
            menu.addItem(startItem)
        }
        
        // 打开 Dashboard
        let dashboardItem = NSMenuItem(
            title: "打开 Dashboard",
            action: #selector(openDashboard),
            keyEquivalent: ""
        )
        dashboardItem.target = self
        menu.addItem(dashboardItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 自动启动设置（带勾选标记）
        let autoStartItem = NSMenuItem(
            title: "启动时自动开启 Gateway",
            action: #selector(toggleAutoStart),
            keyEquivalent: ""
        )
        autoStartItem.target = self
        autoStartItem.state = SettingsManager.shared.autoStartGateway ? .on : .off
        menu.addItem(autoStartItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 退出
        let quitItem = NSMenuItem(
            title: "退出",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        // 显示菜单
        self.statusItem.menu = menu
        self.statusItem.button?.performClick(nil)
        self.statusItem.menu = nil
    }
    
    func checkStatus() {
        gatewayRunning = gatewayManager.isGatewayRunning()
        updateIcon()
    }
    
    func updateIcon() {
        guard let button = statusItem.button else { return }
        
        // 清除标题，使用纯图标
        button.title = ""
        
        // 根据状态选择图标
        let altSymbol = gatewayRunning ? "checkmark.circle.fill" : "xmark.circle.fill"
        let color = gatewayRunning ? NSColor.systemGreen : NSColor.systemRed
        
        if let image = NSImage(systemSymbolName: altSymbol, accessibilityDescription: "OpenClaw MenuBar") {
            // 配置图标颜色和大小
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
                .applying(NSImage.SymbolConfiguration(paletteColors: [color]))
            button.image = image.withSymbolConfiguration(config)
        }
        
        // 如果系统图标不可用，使用 emoji 作为后备
        if button.image == nil {
            button.title = gatewayRunning ? "🟢" : "🔴"
        }
    }
    
    @objc func stopGateway() {
        gatewayManager.stopGateway()
        // 2秒后检查状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.checkStatus()
        }
    }
    
    @objc func startGateway() {
        gatewayManager.startGateway()
        // 3秒后检查状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.checkStatus()
        }
    }
    
    @objc func restartGateway() {
        gatewayManager.restartGateway()
        // 3秒后检查状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.checkStatus()
        }
    }
    
    @objc func openDashboard() {
        if let url = URL(string: "http://127.0.0.1:18789") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func toggleAutoStart() {
        let current = SettingsManager.shared.autoStartGateway
        SettingsManager.shared.autoStartGateway = !current
        print("自动启动 Gateway 已\(!current ? "启用" : "禁用")")
    }
}
