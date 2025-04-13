import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
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
            
            VStack(spacing: 8) {
                // Title
                Text("ComEd Price")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Price
                Text(formatPrice(entry.price))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor(entry.status))
                
                // Status icon
                Image(systemName: statusIcon(entry.status))
                    .font(.title2)
                    .foregroundColor(statusColor(entry.status))
                
                // Price status
                Text(statusText(entry.status))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor(entry.status))
                
                // Last updated
                Text("Updated \(timeAgo(entry.date))")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .padding(8)
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
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallWidgetView(entry: SimpleEntry(date: Date(), price: 12.5, status: .high))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SmallWidgetView(entry: SimpleEntry(date: Date(), price: 5.5, status: .normal))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SmallWidgetView(entry: SimpleEntry(date: Date(), price: 1.5, status: .low))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}