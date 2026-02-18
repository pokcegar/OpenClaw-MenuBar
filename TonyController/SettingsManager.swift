import Foundation

/// 管理 Tony Controller 的设置
class SettingsManager {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let autoStartGateway = "autoStartGateway"
        static let statusCheckInterval = "statusCheckInterval"
    }
    
    private init() {}
    
    /// 是否在启动 Controller 时自动启动 Gateway
    var autoStartGateway: Bool {
        get {
            // 默认开启自动启动
            return defaults.object(forKey: Keys.autoStartGateway) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.autoStartGateway)
        }
    }
    
    /// 状态检查间隔（秒）
    var statusCheckInterval: TimeInterval {
        get {
            return defaults.object(forKey: Keys.statusCheckInterval) as? TimeInterval ?? 5.0
        }
        set {
            defaults.set(newValue, forKey: Keys.statusCheckInterval)
        }
    }
}
