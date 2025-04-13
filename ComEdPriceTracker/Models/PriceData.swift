import Foundation

// Model for the price data returned from the ComEd API
struct PricePoint: Identifiable, Codable {
    var id = UUID()
    let millisUTC: Int
    let price: Double
    
    // Computed property to get a Date from millisUTC
    var timestamp: Date {
        return Date(timeIntervalSince1970: Double(millisUTC) / 1000)
    }
    
    // To conform to Codable since we added a custom id
    enum CodingKeys: String, CodingKey {
        case millisUTC, price
    }
}

// Model for the price data response from the API
struct PriceResponse: Codable {
    let priceData: [PricePoint]
}

class PriceDataStore: ObservableObject {
    @Published var currentPrice: Double = 0.0
    @Published var priceHistory: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let apiService = APIService()
    
    func fetchCurrentPrice() {
        isLoading = true
        errorMessage = ""
        
        apiService.fetchLivePrice { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let prices):
                    if let latestPrice = prices.priceData.last {
                        self?.currentPrice = latestPrice.price
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchPriceHistory() {
        isLoading = true
        errorMessage = ""
        
        apiService.fetchHistoricalPrices { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let prices):
                    self?.priceHistory = prices.priceData
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}