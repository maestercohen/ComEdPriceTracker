import Foundation
import Combine

class UserSettings: ObservableObject {
    // Published properties so SwiftUI views update when they change
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
    
    // Default values and load from UserDefaults if available
    init() {
        self.highPriceThreshold = UserDefaults.standard.double(forKey: "highPriceThreshold")
        if self.highPriceThreshold == 0 {
            self.highPriceThreshold = 10.0  // Default high price threshold (cents per kWh)
        }
        
        self.lowPriceThreshold = UserDefaults.standard.double(forKey: "lowPriceThreshold")
        if self.lowPriceThreshold == 0 {
            self.lowPriceThreshold = 2.0   // Default low price threshold (cents per kWh)
        }
        
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        self.refreshInterval = UserDefaults.standard.integer(forKey: "refreshInterval")
        if self.refreshInterval == 0 {
            self.refreshInterval = 30      // Default refresh interval (minutes)
        }
    }
    
    // Method to reset settings to defaults
    func resetToDefaults() {
        self.highPriceThreshold = 10.0
        self.lowPriceThreshold = 2.0
        self.notificationsEnabled = true
        self.refreshInterval = 30
    }
}