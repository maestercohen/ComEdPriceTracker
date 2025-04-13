import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            if let price = entry.price, let timestamp = entry.priceTimestamp {
                // Show price data
                VStack(spacing: 6) {
                    // Price display
                    Text("\(String(format: "%.1f", price))¢")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("per kWh")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
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
                    
                    // Last updated
                    Text(formatTime(timestamp))
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            } else {
                // Show error state
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text("Price Unavailable")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    if let error = entry.error {
                        Text(error)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, MMM d"
        return formatter.string(from: date)
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Low price
            SmallWidgetView(entry: SimpleEntry(
                date: Date(),
                price: 2.5,
                priceTimestamp: Date(),
                widgetFamily: .systemSmall
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Medium price
            SmallWidgetView(entry: SimpleEntry(
                date: Date(),
                price: 8.3,
                priceTimestamp: Date(),
                widgetFamily: .systemSmall
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // High price
            SmallWidgetView(entry: SimpleEntry(
                date: Date(),
                price: 15.6,
                priceTimestamp: Date(),
                widgetFamily: .systemSmall
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Negative price
            SmallWidgetView(entry: SimpleEntry(
                date: Date(),
                price: -1.2,
                priceTimestamp: Date(),
                widgetFamily: .systemSmall
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Error state
            SmallWidgetView(entry: SimpleEntry(
                date: Date(),
                price: nil,
                priceTimestamp: nil,
                error: "Network error",
                widgetFamily: .systemSmall
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
