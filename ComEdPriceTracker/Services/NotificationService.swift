import Foundation
import UserNotifications

class NotificationService {
    // Singleton instance
    static let shared = NotificationService()
    
    private init() {}
    
    // Request authorization for notifications
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                completion(granted)
            }
        }
    }
    
    // Check notification authorization status
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                completion(isAuthorized)
            }
        }
    }
    
    // Schedule price alert notification
    func schedulePriceAlert(for priceType: PriceAlertType, price: Double) {
        // Create content
        let content = UNMutableNotificationContent()
        
        switch priceType {
        case .high:
            content.title = "High Price Alert"
            content.body = "Current price is above your threshold: \(String(format: "%.2f", price))¢ per kWh"
            content.sound = .default
        case .low:
            content.title = "Low Price Alert"
            content.body = "Current price is below your threshold: \(String(format: "%.2f", price))¢ per kWh"
            content.sound = .default
        }
        
        // Create trigger - immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create request with a unique identifier
        let identifier = "\(priceType.rawValue)_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Remove all pending notifications
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

enum PriceAlertType: String {
    case high = "highPriceAlert"
    case low = "lowPriceAlert"
}