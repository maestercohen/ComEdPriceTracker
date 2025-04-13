import SwiftUI

struct PriceDisplay: View {
    let price: Double
    let highThreshold: Double
    let lowThreshold: Double
    
    var body: some View {
        VStack {
            Text("Current Electricity Price")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(String(format: "%.2f", price))")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(priceColor)
                Text("¢/kWh")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            
            // Price status indicator
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(priceColor)
                Text(statusText)
                    .foregroundColor(priceColor)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(priceColor.opacity(0.1))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    // Computed property for price color
    private var priceColor: Color {
        if price >= highThreshold {
            return .red
        } else if price <= lowThreshold {
            return .green
        } else {
            return .blue
        }
    }
    
    // Computed property for status text
    private var statusText: String {
        if price >= highThreshold {
            return "High Price"
        } else if price <= lowThreshold {
            return "Low Price"
        } else {
            return "Normal Price"
        }
    }
    
    // Computed property for status icon
    private var statusIcon: String {
        if price >= highThreshold {
            return "arrow.up.circle.fill"
        } else if price <= lowThreshold {
            return "arrow.down.circle.fill"
        } else {
            return "equal.circle.fill"
        }
    }
}

struct PriceDisplay_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PriceDisplay(price: 12.5, highThreshold: 10.0, lowThreshold: 2.0)
            PriceDisplay(price: 5.5, highThreshold: 10.0, lowThreshold: 2.0)
            PriceDisplay(price: 1.5, highThreshold: 10.0, lowThreshold: 2.0)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}