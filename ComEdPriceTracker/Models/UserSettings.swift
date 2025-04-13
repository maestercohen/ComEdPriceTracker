import Foundation
import Combine

class UserSettings: ObservableObject {
    // Default values for properties
    private let defaultHighPriceThreshold: Double = 10.0  // cents per kWh
    private let defaultLowPriceThreshold: Double = 2.0    // cents per kWh
    private let defaultNotificationsEnabled: Bool = true
    private let defaultRefreshInterval: Int = 30          // minutes
    
    // Published properties so SwiftUI views update when they change
    // Initialize with default values first to prevent "self used before initialization" errors
    @Published var highPriceThreshold: Double = 10.0 {
        didSet {
            UserDefaults.standard.set(highPriceThreshold, forKey: "highPriceThreshold")
        }
    }
    
    @Published var lowPriceThreshold: Double = 2.0 {
        didSet {
            UserDefaults.standard.set(lowPriceThreshold, forKey: "lowPriceThreshold")
        }
    }
    
    @Published var notificationsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var refreshInterval: Int = 30 {
        didSet {
            UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval")
        }
    }
    
    // Load from UserDefaults if available
    init() {
        // Load values from UserDefaults, only after properties are initialized above
        let storedHighThreshold = UserDefaults.standard.double(forKey: "highPriceThreshold")
        if storedHighThreshold != 0 {
            self.highPriceThreshold = storedHighThreshold
        }
        
        let storedLowThreshold = UserDefaults.standard.double(forKey: "lowPriceThreshold")
        if storedLowThreshold != 0 {
            self.lowPriceThreshold = storedLowThreshold
        }
        
        // For boolean values, we need to check if the key exists because false is the default for bool(forKey:)
        if UserDefaults.standard.object(forKey: "notificationsEnabled") != nil {
            self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        }
        
        let storedRefreshInterval = UserDefaults.standard.integer(forKey: "refreshInterval")
        if storedRefreshInterval != 0 {
            self.refreshInterval = storedRefreshInterval
        }
    }
    
    // Method to reset settings to defaults
    func resetToDefaults() {
        self.highPriceThreshold = defaultHighPriceThreshold
        self.lowPriceThreshold = defaultLowPriceThreshold
        self.notificationsEnabled = defaultNotificationsEnabled
        self.refreshInterval = defaultRefreshInterval
    }
}