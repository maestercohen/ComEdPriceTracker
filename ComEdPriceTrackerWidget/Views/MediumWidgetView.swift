import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(UIColor.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            HStack {
                // Left side - Price
                VStack(alignment: .center, spacing: 8) {
                    Text("Current Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatPrice(entry.price))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(statusColor(entry.status))
                    
                    HStack(spacing: 4) {
                        Image(systemName: statusIcon(entry.status))
                            .foregroundColor(statusColor(entry.status))
                        
                        Text(statusText(entry.status))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(statusColor(entry.status))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor(entry.status).opacity(0.1))
                    .cornerRadius(4)
                }
                .frame(maxWidth: .infinity)
                
                // Vertical divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                    .padding(.vertical, 10)
                
                // Right side - Information
                VStack(alignment: .leading, spacing: 10) {
                    // Thresholds info
                    VStack(alignment: .leading, spacing: 4) {
                        ThresholdRow(name: "High", value: getUserHighThreshold(), color: .red)
                        ThresholdRow(name: "Low", value: getUserLowThreshold(), color: .green)
                    }
                    
                    Spacer()
                    
                    // Updated time
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("Updated \(timeAgo(entry.date))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
    
    // Helper function to get status text
    private func statusText(_ status: PriceStatus) -> String {
        switch status {
        case .high:
            return "High Price"
        case .normal:
            return "Normal Price"
        case .low:
            return "Low Price"
        }
    }
    
    // Helper function to format time ago
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // Get user high threshold from UserDefaults
    private func getUserHighThreshold() -> Double {
        let defaults = UserDefaults(suiteName: "group.com.yourname.ComEdPriceTracker") ?? UserDefaults.standard
        let threshold = defaults.double(forKey: "highPriceThreshold")
        return threshold > 0 ? threshold : 10.0 // Default value
    }
    
    // Get user low threshold from UserDefaults
    private func getUserLowThreshold() -> Double {
        let defaults = UserDefaults(suiteName: "group.com.yourname.ComEdPriceTracker") ?? UserDefaults.standard
        let threshold = defaults.double(forKey: "lowPriceThreshold")
        return threshold > 0 ? threshold : 2.0 // Default value
    }
}

// Threshold row component
struct ThresholdRow: View {
    let name: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: name == "High" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundColor(color)
                .font(.caption)
            
            Text("\(name):")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(String(format: "%.1f¢", value))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct MediumWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MediumWidgetView(entry: SimpleEntry(date: Date(), price: 12.5, status: .high))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            MediumWidgetView(entry: SimpleEntry(date: Date(), price: 5.5, status: .normal))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            MediumWidgetView(entry: SimpleEntry(date: Date(), price: 1.5, status: .low))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}