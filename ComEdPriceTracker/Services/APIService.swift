import Foundation

enum APIError: Error {
    case networkError
    case decodingError
    case invalidURL
    case noData
    case serverError(Int)
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .decodingError:
            return "Error parsing response data."
        case .invalidURL:
            return "Invalid URL."
        case .noData:
            return "No data received from the server."
        case .serverError(let code):
            return "Server error with code: \(code)."
        }
    }
}

class APIService {
    // Base URL for ComEd hourly pricing API
    private let baseURL = "https://hourlypricing.comed.com/api"
    
    // Fetch the current live price
    func fetchLivePrice(completion: @escaping (Result<PriceResponse, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/5minute.json") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(.networkError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError))
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
                // API returns an array, wrap in our response model
                let pricePoints = try JSONDecoder().decode([PricePoint].self, from: data)
                let priceResponse = PriceResponse(priceData: pricePoints)
                completion(.success(priceResponse))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // Fetch historical prices (last 24 hours by default)
    func fetchHistoricalPrices(completion: @escaping (Result<PriceResponse, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/hourly.json") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(.networkError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError))
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
                let pricePoints = try JSONDecoder().decode([PricePoint].self, from: data)
                let priceResponse = PriceResponse(priceData: pricePoints)
                completion(.success(priceResponse))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}