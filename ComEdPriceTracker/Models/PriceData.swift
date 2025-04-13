import Foundation
import SwiftUI

// MARK: - Price Data Models
struct CurrentPrice: Codable, Identifiable {
    var id = UUID()
    let price: Double
    let timestamp: Date
    let millicents: Int
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return (formatter.string(from: NSNumber(value: price)) ?? "0.0") + "¢"
    }
    
    var isNegative: Bool {
        return price < 0
    }
    
    var priceColor: Color {
        if price < 0 {
            return .green
        } else if price < 5.0 {
            return .green
        } else if price < 14.0 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var priceDescription: String {
        if price < 0 {
            return "Negative price - being paid to use electricity!"
        } else if price < 5.0 {
            return "Low price - good time to use appliances"
        } else if price < 14.0 {
            return "Medium price - moderate electricity usage advised"
        } else {
            return "High price - consider reducing electricity usage"
        }
    }
}

struct PricePoint: Codable, Identifiable {
    var id = UUID()
    let price: Double
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case price = "price"
        case timestamp = "millisUTC"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let priceString = try container.decode(String.self, forKey: .price)
        price = Double(priceString) ?? 0.0
        
        let millisUTC = try container.decode(Int64.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: TimeInterval(millisUTC) / 1000.0)
    }
    
    init(price: Double, timestamp: Date) {
        self.price = price
        self.timestamp = timestamp
    }
}

struct HourlyPrice: Codable, Identifiable {
    var id = UUID()
    let price: Double
    let hour: Int
    let date: Date
    
    var formattedHour: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date)
    }
}

struct DailyPriceData {
    let date: Date
    let averagePrice: Double
    let minPrice: Double
    let maxPrice: Double
    let pricePoints: [HourlyPrice]
}

// MARK: - API Response Models
struct APIResponse: Codable {
    let millisUTC: Int64
    let price: String
}

class PriceDataModel: ObservableObject {
    @Published var currentPrice: CurrentPrice?
    @Published var todayPrices: [HourlyPrice] = []
    @Published var weeklyPrices: [DailyPriceData] = []
    @Published var fiveMinutePrices: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let apiService = APIService()
    
    init() {
        fetchCurrentPrice()
        setupRefreshTimer()
        
        // Listen for refresh notifications from SceneDelegate
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RefreshPriceData"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.fetchCurrentPrice()
        }
    }
    
    func setupRefreshTimer() {
        // Refresh price data every 5 minutes
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.fetchCurrentPrice()
            self?.fetchFiveMinutePrices()
        }
    }
    
    func fetchCurrentPrice() {
        isLoading = true
        errorMessage = nil
        
        apiService.fetchCurrentPrice { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let price):
                    self?.currentPrice = price
                    
                    // Check for price threshold notifications
                    NotificationService.shared.checkPriceThresholds(currentPrice: price)
                    
                case .failure(let error):
                    self?.errorMessage = "Failed to load current price: \(error.localizedDescription)"
                }
            }
        }
        
        // Also fetch today's hourly prices
        fetchTodayPrices()
    }
    
    func fetchTodayPrices() {
        apiService.fetchTodayPrices { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let prices):
                    self?.todayPrices = prices
                case .failure(let error):
                    self?.errorMessage = "Failed to load today's prices: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func fetchFiveMinutePrices() {
        apiService.fetchFiveMinutePrices { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let prices):
                    self?.fiveMinutePrices = prices
                case .failure(let error):
                    print("Failed to load 5-minute prices: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchWeeklyPrices() {
        apiService.fetchWeeklyPrices { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let prices):
                    self?.weeklyPrices = prices
                case .failure(let error):
                    self?.errorMessage = "Failed to load weekly prices: \(error.localizedDescription)"
                }
            }
        }
    }
}
