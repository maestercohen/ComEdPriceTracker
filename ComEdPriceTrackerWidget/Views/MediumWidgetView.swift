import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            if let price = entry.price, let timestamp = entry.priceTimestamp {
                // Show price data
                HStack {
                    // Left side: Price display
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ComEd Hourly Price")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        // Price
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(String(format: "%.1f", price))")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("¢/kWh")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // Price status
                        HStack {
                            if price < 0 {
                                Image(systemName: "dollarsign.arrow.circlepath")
                                    .symbolRenderingMode(.multicolor)
                            } else if price < 5.0 {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                            } else if price < 14.0 {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.yellow)
                            } else {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.red)
                            }
                            
                            Text(getPriceLabel(price))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(getPriceColor(price).opacity(0.3))
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        // Last updated
                        Text(formatTime(timestamp))
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.leading)
                    .padding(.vertical)
                    
                    Spacer()
                    
                    // Right side: Info and advice
                    VStack(alignment: .trailing, spacing: 10) {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(getPriceAdvice(price))
                                .font(.caption)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        
                        Image(systemName: getPriceIcon(price))
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.trailing)
                    .padding(.vertical)
                }
            } else {
                // Show error state
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("Price Unavailable")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if let error = entry.error {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Text("Tap to refresh")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        if let price = entry.price {
            return LinearGradient(
                colors: getBackgroundGradient(price),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)
        } else {
            return LinearGradient(
                colors: [Color(.darkGray), Color(.gray)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)
        }
    }
    
    private func getBackgroundGradient(_ price: Double) -> [Color] {
        if price < 0 {
            return [Color(red: 0.0, green: 0.6, blue: 0.3), Color(red: 0.0, green: 0.4, blue: 0.2)]
        } else if price < 5.0 {
            return [Color(red: 0.0, green: 0.5, blue: 0.3), Color(red: 0.0, green: 0.3, blue: 0.2)]
        } else if price < 14.0 {
            return [Color(red: 0.8, green: 0.6, blue: 0.0), Color(red: 0.6, green: 0.4, blue: 0.0)]
        } else {
            return [Color(red: 0.8, green: 0.2, blue: 0.2), Color(red: 0.6, green: 0.1, blue: 0.1)]
        }
    }
    
    private func getPriceColor(_ price: Double) -> Color {
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
    
    private func getPriceIcon(_ price: Double) -> String {
        if price < 0 {
            return "dollarsign.arrow.circlepath"
        } else if price < 5.0 {
            return "lightbulb.fill"
        } else if price < 14.0 {
            return "exclamationmark.circle"
        } else {
            return "bolt.slash.fill"
        }
    }
    
    private func getPriceLabel(_ price: Double) -> String {
        if price < 0 {
            return "NEGATIVE"
        } else if price < 5.0 {
            return "LOW"
        } else if price < 14.0 {
            return "MEDIUM"
        } else {
            return "HIGH"
        }
    }
    
    private func getPriceAdvice(_ price: Double) -> String {
        if price < 0 {
            return "Being paid to use electricity! Great time to use appliances."
        } else if price < 5.0 {
            return "Low price. Good time to run large appliances."
        } else if price < 14.0 {
            return "Medium price. Moderate electricity usage advised."
        } else {
            return "High price. Consider reducing electricity usage."
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, MMM d"
        return formatter.string(from: date)
    }
}

struct MediumWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Low price
            MediumWidgetView(entry: SimpleEntry(
                date: Date(),
                price: 2.5,
                priceTimestamp: Date(),
                widgetFamily: .systemMedium
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            // Medium price
            MediumWidgetView(entry: SimpleEntry(
                date: Date(),
                price: 8.3,
                priceTimestamp: Date(),
                widgetFamily: .systemMedium
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            // High price
            MediumWidgetView(entry: SimpleEntry(
                date: Date(),
                price: 15.6,
                priceTimestamp: Date(),
                widgetFamily: .systemMedium
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            // Negative price
            MediumWidgetView(entry: SimpleEntry(
                date: Date(),
                price: -1.2,
                priceTimestamp: Date(),
                widgetFamily: .systemMedium
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            // Error state
            MediumWidgetView(entry: SimpleEntry(
                date: Date(),
                price: nil,
                priceTimestamp: nil,
                error: "Network error",
                widgetFamily: .systemMedium
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
