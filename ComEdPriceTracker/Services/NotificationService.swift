import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private var lastHighPriceNotificationTime: Date?
    private var lastLowPriceNotificationTime: Date?
    private var lastNegativePriceNotificationTime: Date?
    
    private init() {}
    
    func checkPriceThresholds(currentPrice: CurrentPrice) {
        // Only check if notifications are enabled
        guard UserSettings.shared.notificationsEnabled else { return }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Check for high price alert
        if currentPrice.price >= UserSettings.shared.highPriceThreshold {
            // Only send a high price notification once every 2 hours
            if let lastTime = lastHighPriceNotificationTime {
                let hoursElapsed = calendar.dateComponents([.hour], from: lastTime, to: now).hour ?? 0
                if hoursElapsed >= 2 {
                    sendHighPriceNotification(price: currentPrice)
                    lastHighPriceNotificationTime = now
                }
            } else {
                sendHighPriceNotification(price: currentPrice)
                lastHighPriceNotificationTime = now
            }
        }
        
        // Check for low price alert
        if currentPrice.price <= UserSettings.shared.lowPriceThreshold && currentPrice.price >= 0 {
            // Only send a low price notification once every 2 hours
            if let lastTime = lastLowPriceNotificationTime {
                let hoursElapsed = calendar.dateComponents([.hour], from: lastTime, to: now).hour ?? 0
                if hoursElapsed >= 2 {
                    sendLowPriceNotification(price: currentPrice)
                    lastLowPriceNotificationTime = now
                }
            } else {
                sendLowPriceNotification(price: currentPrice)
                lastLowPriceNotificationTime = now
            }
        }
        
        // Check for negative price alert
        if currentPrice.price < 0 && UserSettings.shared.negativePriceAlerts {
            // Only send a negative price notification once every 1 hour
            if let lastTime = lastNegativePriceNotificationTime {
                let hoursElapsed = calendar.dateComponents([.hour], from: lastTime, to: now).hour ?? 0
                if hoursElapsed >= 1 {
                    sendNegativePriceNotification(price: currentPrice)
                    lastNegativePriceNotificationTime = now
                }
            } else {
                sendNegativePriceNotification(price: currentPrice)
                lastNegativePriceNotificationTime = now
            }
        }
    }
    
    private func sendHighPriceNotification(price: CurrentPrice) {
        let content = UNMutableNotificationContent()
        content.title = "High Electricity Price Alert"
        content.body = "Current price is \(price.formattedPrice) - Consider reducing electricity usage"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "PRICE_ALERT"
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendLowPriceNotification(price: CurrentPrice) {
        let content = UNMutableNotificationContent()
        content.title = "Low Electricity Price Alert"
        content.body = "Current price is \(price.formattedPrice) - Good time to run appliances"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "PRICE_ALERT"
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendNegativePriceNotification(price: CurrentPrice) {
        let content = UNMutableNotificationContent()
        content.title = "Negative Electricity Price Alert!"
        content.body = "Current price is \(price.formattedPrice) - You're being paid to use electricity!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "PRICE_ALERT"
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
