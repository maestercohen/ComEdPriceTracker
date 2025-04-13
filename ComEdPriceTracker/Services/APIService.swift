import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case noData
    case apiRateLimitExceeded
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .noData:
            return "No data received"
        case .apiRateLimitExceeded:
            return "API rate limit exceeded"
        }
    }
}

class APIService {
    // ComEd API endpoints
    private let baseURL = "https://hourlypricing.comed.com/api"
    private let currentPriceEndpoint = "?type=5minutefeed"
    private let hourlyPriceEndpoint = "?type=hourlyfeed"
    private let dayAheadPriceEndpoint = "?type=dayahead"
    
    // MARK: - Current Price
    func fetchCurrentPrice(completion: @escaping (Result<CurrentPrice, APIError>) -> Void) {
        let urlString = "\(baseURL)\(currentPriceEndpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponses = try decoder.decode([APIResponse].self, from: data)
                
                // Get the most recent price from the array
                if let latestPrice = apiResponses.first {
                    let price = Double(latestPrice.price) ?? 0.0
                    let priceInCents = price / 10.0 // Convert millicents to cents
                    let timestamp = Date(timeIntervalSince1970: TimeInterval(latestPrice.millisUTC) / 1000.0)
                    let millicents = Int(price)
                    
                    let currentPrice = CurrentPrice(
                        price: priceInCents,
                        timestamp: timestamp,
                        millicents: millicents
                    )
                    
                    completion(.success(currentPrice))
                } else {
                    completion(.failure(.noData))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Today's Hourly Prices
    func fetchTodayPrices(completion: @escaping (Result<[HourlyPrice], APIError>) -> Void) {
        let urlString = "\(baseURL)\(hourlyPriceEndpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponses = try decoder.decode([APIResponse].self, from: data)
                
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                
                // Filter for today's prices and convert to HourlyPrice objects
                let todayPrices = apiResponses.compactMap { response -> HourlyPrice? in
                    let timestamp = Date(timeIntervalSince1970: TimeInterval(response.millisUTC) / 1000.0)
                    let responseDay = calendar.startOfDay(for: timestamp)
                    
                    if responseDay == today {
                        let price = Double(response.price) ?? 0.0
                        let priceInCents = price / 10.0 // Convert millicents to cents
                        let hour = calendar.component(.hour, from: timestamp)
                        
                        return HourlyPrice(
                            price: priceInCents,
                            hour: hour,
                            date: timestamp
                        )
                    }
                    return nil
                }
                
                // Sort by hour
                let sortedPrices = todayPrices.sorted { $0.hour < $1.hour }
                completion(.success(sortedPrices))
                
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - 5-Minute Prices
    func fetchFiveMinutePrices(completion: @escaping (Result<[PricePoint], APIError>) -> Void) {
        let urlString = "\(baseURL)\(currentPriceEndpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponses = try decoder.decode([APIResponse].self, from: data)
                
                let pricePoints = apiResponses.map { response -> PricePoint in
                    let price = Double(response.price) ?? 0.0
                    let priceInCents = price / 10.0 // Convert millicents to cents
                    let timestamp = Date(timeIntervalSince1970: TimeInterval(response.millisUTC) / 1000.0)
                    
                    return PricePoint(price: priceInCents, timestamp: timestamp)
                }
                
                // Sort by timestamp (newest first)
                let sortedPrices = pricePoints.sorted { $0.timestamp > $1.timestamp }
                completion(.success(sortedPrices))
                
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Weekly Prices
    func fetchWeeklyPrices(completion: @escaping (Result<[DailyPriceData], APIError>) -> Void) {
        let urlString = "\(baseURL)\(hourlyPriceEndpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponses = try decoder.decode([APIResponse].self, from: data)
                
                let calendar = Calendar.current
                let now = Date()
                
                // Group by day for the last 7 days
                let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                
                // Convert all prices to HourlyPrice objects
                let hourlyPrices = apiResponses.compactMap { response -> HourlyPrice? in
                    let timestamp = Date(timeIntervalSince1970: TimeInterval(response.millisUTC) / 1000.0)
                    
                    if timestamp >= sevenDaysAgo {
                        let price = Double(response.price) ?? 0.0
                        let priceInCents = price / 10.0 // Convert millicents to cents
                        let hour = calendar.component(.hour, from: timestamp)
                        
                        return HourlyPrice(
                            price: priceInCents,
                            hour: hour,
                            date: timestamp
                        )
                    }
                    return nil
                }
                
                // Group by day
                let groupedByDay = Dictionary(grouping: hourlyPrices) { price in
                    calendar.startOfDay(for: price.date)
                }
                
                // Create DailyPriceData for each day
                let dailyData = groupedByDay.map { (date, prices) -> DailyPriceData in
                    let sortedPrices = prices.sorted { $0.hour < $1.hour }
                    let priceValues = prices.map { $0.price }
                    let averagePrice = priceValues.reduce(0, +) / Double(priceValues.count)
                    let minPrice = priceValues.min() ?? 0
                    let maxPrice = priceValues.max() ?? 0
                    
                    return DailyPriceData(
                        date: date,
                        averagePrice: averagePrice,
                        minPrice: minPrice,
                        maxPrice: maxPrice,
                        pricePoints: sortedPrices
                    )
                }
                
                // Sort by date (newest first)
                let sortedDailyData = dailyData.sorted { $0.date > $1.date }
                completion(.success(sortedDailyData))
                
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
