import SwiftUI

struct PriceDisplay: View {
    let price: CurrentPrice
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Price")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(price.formattedPrice)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(price.priceColor)
                        
                        Text("per kWh")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Price indicator
                VStack {
                    ZStack {
                        Circle()
                            .fill(price.priceColor.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .stroke(price.priceColor, lineWidth: 3)
                            .frame(width: 60, height: 60)
                        
                        if price.isNegative {
                            Image(systemName: "dollarsign.arrow.circlepath")
                                .font(.system(size: 24))
                                .foregroundColor(price.priceColor)
                        } else if price.price < 5.0 {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 24))
                                .foregroundColor(price.priceColor)
                        } else if price.price < 14.0 {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 24))
                                .foregroundColor(price.priceColor)
                        } else {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 24))
                                .foregroundColor(price.priceColor)
                        }
                    }
                    
                    Text(getPriceLabel(price.price))
                        .font(.caption)
                        .foregroundColor(price.priceColor)
                        .fontWeight(.medium)
                }
            }
            
            // Updated time and description
            VStack(alignment: .leading, spacing: 8) {
                Text(price.priceDescription)
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                    .cornerRadius(8)
                
                Text("Last updated: \(formatTime(price.timestamp))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .cornerRadius(16)
        .shadow(radius: 3)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, MMM d"
        return formatter.string(from: date)
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
}

struct PriceDisplay_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PriceDisplay(price: CurrentPrice(price: 2.5, timestamp: Date(), millicents: 25))
                .padding()
            
            PriceDisplay(price: CurrentPrice(price: 8.7, timestamp: Date(), millicents: 87))
                .padding()
            
            PriceDisplay(price: CurrentPrice(price: 16.3, timestamp: Date(), millicents: 163))
                .padding()
            
            PriceDisplay(price: CurrentPrice(price: -1.2, timestamp: Date(), millicents: -12))
                .padding()
        }
    }
}
