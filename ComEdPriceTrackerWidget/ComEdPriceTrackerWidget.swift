import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), price: 5.25, status: .normal)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        // For previews and when adding the widget, show a sample entry
        let entry = SimpleEntry(date: Date(), price: 5.25, status: .normal)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Fetch the latest price from API
        fetchCurrentPrice { result in
            var entries: [SimpleEntry] = []
            let currentDate = Date()
            
            switch result {
            case .success(let priceResponse):
                if let latestPrice = priceResponse.priceData.last {
                    // Get user settings for thresholds
                    let userSettings = getUserSettings()
                    
                    // Determine price status based on thresholds
                    var status: PriceStatus = .normal
                    if latestPrice.price >= userSettings.highThreshold {
                        status = .high
                    } else if latestPrice.price <= userSettings.lowThreshold {
                        status = .low
                    }
                    
                    // Create entry with the latest price
                    let entry = SimpleEntry(
                        date: latestPrice.timestamp,
                        price: latestPrice.price,
                        status: status
                    )
                    entries.append(entry)
                } else {
                    // Fallback to placeholder if no data
                    entries.append(SimpleEntry(date: currentDate, price: 0.0, status: .normal))
                }
                
            case .failure:
                // Fallback to placeholder on error
                entries.append(SimpleEntry(date: currentDate, price: 0.0, status: .normal))
            }
            
            // Schedule next update in 30 minutes
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    // Function to fetch current price data
    private func fetchCurrentPrice(completion: @escaping (Result<PriceResponse, Error>) -> Void) {
        guard let url = URL(string: "https://hourlypricing.comed.com/api/5minute.json") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let pricePoints = try JSONDecoder().decode([PricePoint].self, from: data)
                let priceResponse = PriceResponse(priceData: pricePoints)
                completion(.success(priceResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Get user settings from UserDefaults
    private func getUserSettings() -> (highThreshold: Double, lowThreshold: Double) {
        let defaults = UserDefaults(suiteName: "group.com.yourname.ComEdPriceTracker") ?? UserDefaults.standard
        
        let highThreshold = defaults.double(forKey: "highPriceThreshold")
        let lowThreshold = defaults.double(forKey: "lowPriceThreshold")
        
        // Use default values if not set
        return (
            highThreshold: highThreshold > 0 ? highThreshold : 10.0,
            lowThreshold: lowThreshold > 0 ? lowThreshold : 2.0
        )
    }
}

// Widget entry model
struct SimpleEntry: TimelineEntry {
    let date: Date
    let price: Double
    let status: PriceStatus
}

// Price status enum
enum PriceStatus {
    case high
    case normal
    case low
}

// Define the widget
struct ComEdPriceTrackerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry) // Fallback to small
        }
    }
}

// Widget configuration
@main
struct ComEdPriceTrackerWidget: Widget {
    let kind: String = "ComEdPriceTrackerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComEdPriceTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ComEd Price Tracker")
        .description("View the current ComEd hourly electricity price.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Helper function to format price
func formatPrice(_ price: Double) -> String {
    String(format: "%.2f¢", price)
}

// Helper function to get an icon based on price status
func statusIcon(_ status: PriceStatus) -> String {
    switch status {
    case .high:
        return "arrow.up.circle.fill"
    case .normal:
        return "equal.circle.fill"
    case .low:
        return "arrow.down.circle.fill"
    }
}

// Helper function to get a color based on price status
func statusColor(_ status: PriceStatus) -> Color {
    switch status {
    case .high:
        return .red
    case .normal:
        return .blue
    case .low:
        return .green
    }
}

// Custom model types needed for the widget since we can't directly use the app's models
struct PricePoint: Codable, Identifiable {
    var id = UUID()
    let millisUTC: Int
    let price: Double
    
    var timestamp: Date {
        return Date(timeIntervalSince1970: Double(millisUTC) / 1000)
    }
    
    enum CodingKeys: String, CodingKey {
        case millisUTC, price
    }
}

struct PriceResponse: Codable {
    let priceData: [PricePoint]
}

// Preview for widgets
struct ComEdPriceTrackerWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ComEdPriceTrackerWidgetEntryView(
                entry: SimpleEntry(date: Date(), price: 12.5, status: .high)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            ComEdPriceTrackerWidgetEntryView(
                entry: SimpleEntry(date: Date(), price: 5.75, status: .normal)
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            ComEdPriceTrackerWidgetEntryView(
                entry: SimpleEntry(date: Date(), price: 1.8, status: .low)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}