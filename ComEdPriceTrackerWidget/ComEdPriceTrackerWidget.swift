import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), price: 2.3, priceTimestamp: Date(), widgetFamily: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), price: 2.3, priceTimestamp: Date(), widgetFamily: context.family)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        fetchCurrentPrice { price, timestamp, error in
            var entries: [SimpleEntry] = []
            let currentDate = Date()
            
            if let price = price, let timestamp = timestamp {
                // Create entry with fetched price
                let entry = SimpleEntry(
                    date: currentDate,
                    price: price,
                    priceTimestamp: timestamp,
                    widgetFamily: context.family
                )
                entries.append(entry)
            } else {
                // Create entry with error state
                let entry = SimpleEntry(
                    date: currentDate,
                    price: nil,
                    priceTimestamp: nil,
                    error: error?.localizedDescription ?? "Failed to load price",
                    widgetFamily: context.family
                )
                entries.append(entry)
            }
            
            // Schedule next update based on user settings
            let updateInterval = UserDefaults(suiteName: "group.com.comedpricetracker")?.integer(forKey: "widgetUpdateFrequency") ?? 30
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: updateInterval, to: currentDate)!
            
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    private func fetchCurrentPrice(completion: @escaping (Double?, Date?, Error?) -> Void) {
        let urlString = "https://hourlypricing.comed.com/api?type=5minutefeed"
        
        guard let url = URL(string: urlString) else {
            completion(nil, nil, NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, nil, NSError(domain: "NoData", code: -2, userInfo: nil))
                return
            }
            
            do {
                // Parse the response
                struct APIResponse: Codable {
                    let millisUTC: Int64
                    let price: String
                }
                
                let decoder = JSONDecoder()
                let apiResponses = try decoder.decode([APIResponse].self, from: data)
                
                if let latestPrice = apiResponses.first {
                    let price = Double(latestPrice.price) ?? 0.0
                    let priceInCents = price / 10.0 // Convert millicents to cents
                    let timestamp = Date(timeIntervalSince1970: TimeInterval(latestPrice.millisUTC) / 1000.0)
                    
                    completion(priceInCents, timestamp, nil)
                } else {
                    completion(nil, nil, NSError(domain: "EmptyResponse", code: -3, userInfo: nil))
                }
            } catch {
                completion(nil, nil, error)
            }
        }.resume()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let price: Double?
    let priceTimestamp: Date?
    let error: String?
    let widgetFamily: WidgetFamily
    
    init(date: Date, price: Double?, priceTimestamp: Date?, error: String? = nil, widgetFamily: WidgetFamily) {
        self.date = date
        self.price = price
        self.priceTimestamp = priceTimestamp
        self.error = error
        self.widgetFamily = widgetFamily
    }
}

struct ComEdPriceTrackerWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        switch entry.widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct ComEdPriceTrackerWidget: Widget {
    let kind: String = "ComEdPriceTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComEdPriceTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ComEd Price")
        .description("Shows the current ComEd hourly electricity price.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ComEdPriceTrackerWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal price preview
            ComEdPriceTrackerWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                price: 2.5,
                priceTimestamp: Date(),
                widgetFamily: .systemSmall
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // High price preview
            ComEdPriceTrackerWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                price: 15.7,
                priceTimestamp: Date(),
                widgetFamily: .systemSmall
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Error state preview
            ComEdPriceTrackerWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                price: nil,
                priceTimestamp: nil,
                error: "Failed to load price",
                widgetFamily: .systemSmall
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Medium widget preview
            ComEdPriceTrackerWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                price: 3.2,
                priceTimestamp: Date(),
                widgetFamily: .systemMedium
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
