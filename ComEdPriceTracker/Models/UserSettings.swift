import Foundation
import Combine

class UserSettings: ObservableObject {
    // MARK: - Published Properties
    @Published var highPriceThreshold: Double {
        didSet {
            UserDefaults.standard.set(highPriceThreshold, forKey: "highPriceThreshold")
        }
    }
    
    @Published var lowPriceThreshold: Double {
        didSet {
            UserDefaults.standard.set(lowPriceThreshold, forKey: "lowPriceThreshold")
        }
    }
    
    @Published var negativePriceAlerts: Bool {
        didSet {
            UserDefaults.standard.set(negativePriceAlerts, forKey: "negativePriceAlerts")
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var refreshInterval: Int {
        didSet {
            UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval")
        }
    }
    
    @Published var widgetUpdateFrequency: Int {
        didSet {
            UserDefaults.standard.set(widgetUpdateFrequency, forKey: "widgetUpdateFrequency")
        }
    }
    
    // MARK: - Singleton Instance
    static let shared = UserSettings()
    
    // MARK: - Initialization
    private init() {
        // Set default values if they don't exist
        self.highPriceThreshold = UserDefaults.standard.double(forKey: "highPriceThreshold")
        if self.highPriceThreshold == 0 {
            self.highPriceThreshold = 14.0
            UserDefaults.standard.set(self.highPriceThreshold, forKey: "highPriceThreshold")
        }
        
        self.lowPriceThreshold = UserDefaults.standard.double(forKey: "lowPriceThreshold")
        if self.lowPriceThreshold == 0 {
            self.lowPriceThreshold = 2.0
            UserDefaults.standard.set(self.lowPriceThreshold, forKey: "lowPriceThreshold")
        }
        
        self.negativePriceAlerts = UserDefaults.standard.bool(forKey: "negativePriceAlerts")
        if !UserDefaults.standard.contains(key: "negativePriceAlerts") {
            self.negativePriceAlerts = true
            UserDefaults.standard.set(self.negativePriceAlerts, forKey: "negativePriceAlerts")
        }
        
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        if !UserDefaults.standard.contains(key: "notificationsEnabled") {
            self.notificationsEnabled = true
            UserDefaults.standard.set(self.notificationsEnabled, forKey: "notificationsEnabled")
        }
        
        self.refreshInterval = UserDefaults.standard.integer(forKey: "refreshInterval")
        if self.refreshInterval == 0 {
            self.refreshInterval = 15 // Default to 15 minutes
            UserDefaults.standard.set(self.refreshInterval, forKey: "refreshInterval")
        }
        
        self.widgetUpdateFrequency = UserDefaults.standard.integer(forKey: "widgetUpdateFrequency")
        if self.widgetUpdateFrequency == 0 {
            self.widgetUpdateFrequency = 30 // Default to 30 minutes
            UserDefaults.standard.set(self.widgetUpdateFrequency, forKey: "widgetUpdateFrequency")
        }
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
